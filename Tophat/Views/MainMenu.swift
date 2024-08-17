//
//  MainMenu.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-10-26.
//  Copyright © 2022 Shopify. All rights reserved.
//

import SwiftUI

struct MainMenu: View {
	@Environment(\.showingAdvancedOptions) private var showingAdvancedOptions
	@Environment(\.showOnboardingWindow) private var showOnboardingWindow
	@AppStorage("ShowQuickLaunch") private var showQuickLaunch = true

	@State private var aboutWindowPresented = false

	var body: some View {
		VStack(alignment: .leading, spacing: Theme.Size.menuMargin) {
			MenuHeader()
				.padding(Theme.Size.menuPaddingHorizontal)

			if showQuickLaunch {
				QuickLaunchPanel()
					.padding(.horizontal, Theme.Size.menuPaddingHorizontal)
					.padding(.bottom, Theme.Size.menuMargin)
			} else {
				Divider()
					.padding(.horizontal, Theme.Size.menuPaddingHorizontal)
			}

			DeviceList()

			Divider()
				.padding(.horizontal, Theme.Size.menuPaddingHorizontal)

			LaunchFromLocationMenuItem()

			if showingAdvancedOptions {
				Divider()
					.padding(.horizontal, Theme.Size.menuPaddingHorizontal)

				VStack(alignment: .leading, spacing: 0) {
					Button {
						aboutWindowPresented = true
					} label: {
						Text("About Tophat")
							.foregroundColor(.primary)
					}
					.buttonStyle(MenuItemButtonStyle())

					Button {
						showOnboardingWindow?()
					} label: {
						Text("Show Welcome Window")
							.foregroundColor(.primary)
					}
					.buttonStyle(MenuItemButtonStyle())
				}
			}

			Divider()
				.padding(.horizontal, Theme.Size.menuPaddingHorizontal)

			VStack(alignment: .leading, spacing: 0) {
				Group {
					if #available(macOS 14.0, *) {
						#if compiler(>=5.9)
						SettingsLink {
							Text("Settings…")
								.foregroundColor(.primary)
						}
						#endif
					} else {
						Button {
							NSApp.showSettingsWindow()
						} label: {
							Text("Settings…")
								.foregroundColor(.primary)
						}
					}
				}
				.buttonStyle(MenuItemButtonStyle())

				Button {
					NSApplication.shared.terminate(nil)
				} label: {
					Text("Quit Tophat")
						.foregroundColor(.primary)
				}
				.buttonStyle(MenuItemButtonStyle())
			}
		}
		.padding(Theme.Size.menuMargin)
		.frame(width: 336)
		.aboutWindow(isPresented: $aboutWindowPresented) {
			AboutView()
		}
		.modifier(DeviceIsLockedViewModifier())
	}
}