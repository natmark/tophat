//
//  ArtifactUnpacker.swift
//  Tophat
//
//  Created by Lukas Romsicki on 2022-11-18.
//  Copyright © 2022 Shopify. All rights reserved.
//

import Foundation
import TophatFoundation
import ZIPFoundation

final class ArtifactUnpacker {
	/// Unpacks a local artifact found on the local file system and returns the application contained in the artifact.
	/// - Parameter artifactURL: The URL to the local artifact.
	/// - Returns: An  `Application` instance representing the build found in the artifact.
	func unpack(artifactURL: URL) throws -> Application {
		guard artifactURL.isFileURL else {
			throw ArtifactUnpackerError.artifactNotAvailable
		}

		guard let fileFormat = ArtifactFileFormat(pathExtension: artifactURL.pathExtension) else {
			throw ArtifactUnpackerError.unknownFileFormat
		}

		switch fileFormat {
			case .zip:
                // TODO: hoge.app が hoge.zip に圧縮されている場合に hoge.app ディレクトリに hoge.app を展開した内容を入れてしまい、hoge.app/hoge.app になってしまうことで上手く動かない問題がある
				let extractedURL = try extractArtifact(at: artifactURL)
				return try unpack(artifactURL: extractedURL)

			case .appStorePackage:
				let extractedURL = try extractAppStorePackage(at: artifactURL)
				return AppleApplication(bundleURL: extractedURL, appStorePackageURL: artifactURL)

			case .applicationBundle:
				return AppleApplication(bundleURL: artifactURL)

			case .androidPackage:
				return AndroidApplication(url: artifactURL)
		}
	}

	private func extractAppStorePackage(at url: URL) throws -> URL {
		let extractedPath = try extractArtifact(at: url)

		let fileURLs = try FileManager.default.contentsOfDirectory(
			at: extractedPath.appending(path: "Payload"),
			includingPropertiesForKeys: nil
		)

		guard let fileURL = fileURLs.first(where: { $0.pathExtension == ArtifactFileFormat.applicationBundle.pathExtension }) else {
			throw ArtifactUnpackerError.failedToLocateBundleInAppStorePackage
		}

		return fileURL
	}

	private func extractArtifact(at url: URL) throws -> URL {
        if url.fileName.contains(".app") {
//            // TODO: 一旦雑実装 ( `.app.zip` のような拡張子の場合にディレクトリ名に含めない用にしたい)
//            let destination = url.deletingLastPathComponent() // zipが存在する直下に展開する
//            try FileManager.default.unzipItem(at: url, to: destination)
//            try? FileManager.default.removeItem(at: url)
//
//            return destination.appending(component: url.fileName)
            let destination = url.deletingLastPathComponent().appending(path: url.fileName)

            try FileManager.default.unzipItem(at: url, to: destination)
            try? FileManager.default.removeItem(at: url)

            return destination
        } else {
            let destination = url.deletingLastPathComponent().appending(path: url.fileName)

            try FileManager.default.unzipItem(at: url, to: destination)
            try? FileManager.default.removeItem(at: url)

            return destination
        }
	}
}

private extension URL {
	var fileName: String {
		lastPathComponent.replacingOccurrences(of: ".\(pathExtension)", with: "")
	}
}

enum ArtifactUnpackerError: Error {
	case unknownFileFormat
	case artifactNotAvailable
	case failedToLocateBundleInAppStorePackage
}
