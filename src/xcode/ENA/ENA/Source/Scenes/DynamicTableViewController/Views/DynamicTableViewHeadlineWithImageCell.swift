//
// 🦠 Corona-Warn-App
//

import UIKit

class DynamicTableViewHeadlineWithImageCell: UITableViewCell {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(headline: String, image: UIImage) {
		headlineLabel.text = headline
		backgroundImageView.image = image
	}

	// MARK: - Private

	private let headlineLabel = ENALabel(style: .title1)
	private let backgroundImageView = UIImageView()
	private let gradientView = GradientView(type: .whiteToLightBlue)

	private func setupView() {
		gradientView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(gradientView)

		headlineLabel.translatesAutoresizingMaskIntoConstraints = false
		headlineLabel.numberOfLines = 0
		contentView.addSubview(headlineLabel)

		backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
		backgroundImageView.contentMode = .scaleAspectFit
		contentView.addSubview(backgroundImageView)

		NSLayoutConstraint.activate(
			[
				gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
				gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
				gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
				gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

				headlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 64.0),
				headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -45.0),
				headlineLabel.bottomAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: -12),

				backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
				backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
				backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
			]
		)
	}

}
