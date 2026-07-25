import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins

/// Digital membership card with VIP status and QR payload.
struct MembershipCard: View {
    let membership: Membership

    var body: some View {
        VStack(alignment: .leading, spacing: VelaneraSpacing.lg) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("VELANERA")
                        .font(VelaneraTypography.label(12))
                        .foregroundStyle(VelaneraColors.gold)
                        .tracking(3)
                    Text(membership.tier.displayName)
                        .font(VelaneraTypography.title(26))
                        .foregroundStyle(VelaneraColors.ivory)
                }
                Spacer()
                Image(systemName: "crown.fill")
                    .foregroundStyle(VelaneraColors.gold)
                    .font(.title2)
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(membership.memberName)
                        .font(VelaneraTypography.headline(18))
                        .foregroundStyle(VelaneraColors.champagne)
                    Text("Member since \(DateFormatters.membership.string(from: membership.joinedAt))")
                        .font(VelaneraTypography.caption())
                        .foregroundStyle(VelaneraColors.secondaryText)
                    Text(membership.loyaltyPoints.formatted() + " pts")
                        .font(VelaneraTypography.label(12))
                        .foregroundStyle(VelaneraColors.gold)
                }
                Spacer()
                if let qrImage = QRCodeGenerator.image(from: membership.qrPayload) {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 88)
                        .padding(6)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
        .padding(VelaneraSpacing.lg)
        .background {
            RoundedRectangle(cornerRadius: VelaneraSpacing.radiusLg, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0x1C1810),
                            VelaneraColors.nearBlack,
                            Color(hex: 0x14110C)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: VelaneraSpacing.radiusLg, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [VelaneraColors.gold.opacity(0.7), VelaneraColors.gold.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
    }
}

/// Generates QR code images for membership payloads.
enum QRCodeGenerator {
    static func image(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
