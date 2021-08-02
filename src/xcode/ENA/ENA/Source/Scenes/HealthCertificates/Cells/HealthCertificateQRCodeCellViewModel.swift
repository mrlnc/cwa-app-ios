////
// 🦠 Corona-Warn-App
//

import UIKit

struct HealthCertificateQRCodeCellViewModel {

	// MARK: - Init

	init(
		healthCertificate: HealthCertificate,
		accessibilityText: String?,
		onValidationButtonTap: @escaping (HealthCertificate, @escaping (Bool) -> Void) -> Void
	) {
		self.healthCertificate = healthCertificate
		self.onValidationButtonTap = onValidationButtonTap

		let qrCodeSize = UIScreen.main.bounds.width - 60

		self.qrCodeImage = UIImage.qrCode(
			with: healthCertificate.base45,
			encoding: .utf8,
			size: CGSize(width: qrCodeSize, height: qrCodeSize),
			qrCodeErrorCorrectionLevel: .quartile
		) ?? UIImage()

		self.accessibilityText = accessibilityText

		switch healthCertificate.entry {
		case .vaccination(let vaccinationEntry):
			self.title = AppStrings.HealthCertificate.Person.VaccinationCertificate.headline
			self.subtitle = vaccinationEntry.localVaccinationDate.map {
				String(
					format: AppStrings.HealthCertificate.Person.VaccinationCertificate.vaccinationDate,
					DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
				)
			}
		case .test(let testEntry):
			self.title = AppStrings.HealthCertificate.Person.TestCertificate.headline
			self.subtitle = testEntry.sampleCollectionDate.map {
				String(
					format: AppStrings.HealthCertificate.Person.TestCertificate.sampleCollectionDate,
					DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .short)
				)
			}
		case .recovery(let recoveryEntry):
			self.title = AppStrings.HealthCertificate.Person.RecoveryCertificate.headline
			self.subtitle = recoveryEntry.localCertificateValidityEndDate.map {
				String(
					format: AppStrings.HealthCertificate.Person.RecoveryCertificate.validityDate,
					DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none)
				)
			}
		}
	}

	// MARK: - Internal

	let backgroundColor: UIColor = .enaColor(for: .cellBackground2)
	let borderColor: UIColor = .enaColor(for: .hairline)
	let title: String?
	let subtitle: String?
	let qrCodeImage: UIImage
	let accessibilityText: String?

	func didTapValidationButton(loadingStateHandler: @escaping (Bool) -> Void) {
		onValidationButtonTap(healthCertificate) { isLoading in
			loadingStateHandler(isLoading)
		}
	}

	// MARK: - Private

	private let healthCertificate: HealthCertificate
	private let onValidationButtonTap: (HealthCertificate, @escaping (Bool) -> Void) -> Void

}
