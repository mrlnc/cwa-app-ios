////
// 🦠 Corona-Warn-App
//

import UIKit
import Contacts
import OpenCombine

final class HealthCertifiedPersonViewModel {

	// MARK: - Init

	init(
		healthCertificateService: HealthCertificateService,
		healthCertifiedPerson: HealthCertifiedPerson,
		vaccinationValueSetsProvider: VaccinationValueSetsProvider,
		dismiss: @escaping () -> Void
	) {
		self.healthCertificateService = healthCertificateService
		self.healthCertifiedPerson = healthCertifiedPerson
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider

		// setup gradient update
		healthCertifiedPerson.$vaccinationState
			.sink { [weak self] in
				self?.gradientType = $0.gradientType
			}
			.store(in: &subscriptions)

		healthCertifiedPerson.objectDidChange
			.sink { [weak self] healthCertifiedPerson in
				guard !healthCertifiedPerson.vaccinationCertificates.isEmpty else {
					dismiss()
					return
				}

				self?.triggerReload = true
			}
			.store(in: &subscriptions)

		// load certificate value sets
		vaccinationValueSetsProvider.latestVaccinationCertificateValueSets()
			.sink(
				receiveCompletion: { _ in },
				receiveValue: { _ in }
			)
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum TableViewSection: Int, CaseIterable {
		case header
		case qrCode
		case fullyVaccinatedHint
		case person
		case certificates

		static var numberOfSections: Int {
			allCases.count
		}

		static func map(_ section: Int) -> TableViewSection {
			guard let section = TableViewSection(rawValue: section) else {
				fatalError("unsupported tableView section")
			}
			return section
		}
	}

	let headerCellViewModel: HealthCertificateSimpleTextCellViewModel = {
		let centerParagraphStyle = NSMutableParagraphStyle()
		centerParagraphStyle.alignment = .center
		centerParagraphStyle.lineSpacing = 10.0

		let attributedHeadline = NSAttributedString(
			string: AppStrings.HealthCertificate.Person.title,
			attributes: [
				.font: UIFont.enaFont(for: .headline),
				.foregroundColor: UIColor.enaColor(for: .textContrast),
				.paragraphStyle: centerParagraphStyle
			]
		)

		let attributedSubheadline = NSAttributedString(
			string: AppStrings.HealthCertificate.Person.subtitle,
			attributes: [
				.font: UIFont.enaFont(for: .body),
				.foregroundColor: UIColor.enaColor(for: .textContrast),
				.paragraphStyle: centerParagraphStyle
			]
		)

		return HealthCertificateSimpleTextCellViewModel(
			backgroundColor: .clear,
			textAlignment: .center,
			attributedText: [attributedHeadline, attributedSubheadline].joined(with: "\n"),
			topSpace: 42.0,
			font: .enaFont(for: .headline),
			accessibilityTraits: .staticText
		)
	}()

	@OpenCombine.Published private(set) var gradientType: GradientView.GradientType = .solidGrey
	@OpenCombine.Published private(set) var triggerReload: Bool = false
	@OpenCombine.Published private(set) var updateError: Error?

	var qrCodeCellViewModel: HealthCertificateQRCodeCellViewModel {
		guard let latestHealthCertificate = healthCertifiedPerson.vaccinationCertificates.last
			else {
			fatalError("Cell cannot be shown without a health certificate")
		}

		return HealthCertificateQRCodeCellViewModel(
			healthCertificate: latestHealthCertificate,
			accessibilityText: AppStrings.HealthCertificate.Person.QRCodeImageDescription
		)
	}

	var fullyVaccinatedHintCellViewModel: HealthCertificateSimpleTextCellViewModel {
		guard case .fullyVaccinated(daysUntilCompleteProtection: let daysUntilCompleteProtection) = healthCertifiedPerson.vaccinationState else {
			fatalError("Cell cannot be shown in any other vaccination state than .fullyVaccinated")
		}

		return HealthCertificateSimpleTextCellViewModel(
			backgroundColor: .enaColor(for: .cellBackground2),
			textAlignment: .left,
			text: String(
				format: AppStrings.HealthCertificate.Person.daysUntilCompleteProtection,
				daysUntilCompleteProtection
			),
			topSpace: 16.0,
			font: .enaFont(for: .body),
			borderColor: .enaColor(for: .hairline),
			accessibilityTraits: .staticText
		)
	}

	var fullyVaccinatedHintIsVisible: Bool {
		if case .fullyVaccinated = healthCertifiedPerson.vaccinationState {
			return true
		} else {
			return false
		}
	}

	var personCellViewModel: HealthCertificateSimpleTextCellViewModel {
		let attributedName = NSAttributedString(
			string: healthCertifiedPerson.name?.fullName ?? "",
			attributes: [
				.font: UIFont.enaFont(for: .headline),
				.foregroundColor: UIColor.enaColor(for: .textPrimary1)
			]
		)

		let attributedDetails = NSAttributedString(
			string: dateOfBirth ?? "",
			attributes: [
				.font: UIFont.enaFont(for: .body),
				.foregroundColor: UIColor.enaColor(for: .textPrimary1)
			]
		)

		return HealthCertificateSimpleTextCellViewModel(
			backgroundColor: .enaColor(for: .cellBackground2),
			attributedText: [attributedName, attributedDetails].joined(with: "\n"),
			topSpace: 16.0,
			font: .enaFont(for: .headline),
			borderColor: .enaColor(for: .hairline),
			accessibilityTraits: .staticText
		)
	}

	func numberOfItems(in section: TableViewSection) -> Int {
		switch section {
		case .header:
			return 1
		case .qrCode:
			return 1
		case .fullyVaccinatedHint:
			return fullyVaccinatedHintIsVisible ? 1 : 0
		case .person:
			return 1
		case .certificates:
			return healthCertifiedPerson.vaccinationCertificates.count
		}
	}

	func healthCertificateCellViewModel(row: Int) -> HealthCertificateCellViewModel {
		HealthCertificateCellViewModel(
			healthCertificate: healthCertifiedPerson.vaccinationCertificates[row],
			gradientType: gradientType
		)
	}

	func healthCertificate(for indexPath: IndexPath) -> HealthCertificate? {
		guard TableViewSection.map(indexPath.section) == .certificates,
			  healthCertifiedPerson.vaccinationCertificates.indices.contains(indexPath.row) else {
			return nil
		}
		return healthCertifiedPerson.vaccinationCertificates[indexPath.row]
	}

	func canEditRow(at indexPath: IndexPath) -> Bool {
		return TableViewSection.map(indexPath.section) == .certificates
	}

	func removeHealthCertificate(at indexPath: IndexPath) {
		guard TableViewSection.map(indexPath.section) == .certificates else {
			return
		}

		healthCertificateService.removeHealthCertificate(healthCertifiedPerson.vaccinationCertificates[indexPath.row])
	}

	// MARK: - Private

	private let healthCertifiedPerson: HealthCertifiedPerson
	private let healthCertificateService: HealthCertificateService
	private let vaccinationValueSetsProvider: VaccinationValueSetsProvider
	private var subscriptions = Set<AnyCancellable>()

	private var dateOfBirth: String? {
		guard
			let dateOfBirthString = healthCertifiedPerson.dateOfBirth,
			let dateOfBirthDate = ISO8601DateFormatter.justLocalDateFormatter.date(from: dateOfBirthString)
		else {
			return nil
		}

		return String(
			format: AppStrings.HealthCertificate.Person.dateOfBirth,
			DateFormatter.localizedString(from: dateOfBirthDate, dateStyle: .medium, timeStyle: .none)
		)
	}

}
