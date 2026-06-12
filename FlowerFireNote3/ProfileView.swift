import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color.clear.huahuoBackground()

            VStack(spacing: 16) {
                HStack {
                    BrandHeader()
                }

                Spacer(minLength: 0)

                VStack(spacing: 14) {
                    Image(systemName: "person")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(HuahuoTheme.accent)
                        .frame(width: 88, height: 88)
                        .background(
                            LinearGradient(colors: [HuahuoTheme.butter, HuahuoTheme.rose], startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 31, style: .continuous)
                        )

                    Text("我的花火")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(HuahuoTheme.foreground)

                    Text("这里先作为占位。后续可以放收藏夹、灵感分组和个人主页编辑。")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(HuahuoTheme.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .frame(maxWidth: 260)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 498)
                .padding(24)
                .glassCard(cornerRadius: 34)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationBarHidden(true)
    }
}
