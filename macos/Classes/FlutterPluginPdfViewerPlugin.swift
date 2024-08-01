import FlutterMacOS
import AppKit
import Cocoa
import Quartz

let kDirectory = "FlutterPluginPdfViewer"
var kFileName = ""

public class FlutterPluginPdfViewerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_plugin_pdf_viewer", binaryMessenger: registrar.messenger)
        let instance = FlutterPluginPdfViewerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .default).async {
            if call.method == "getPage" {
                guard let arguments = call.arguments as? [String: Any],
                      let pageNumber = arguments["pageNumber"] as? Int,
                      let filePath = arguments["filePath"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                    return
                }
                result(self.getPage(filePath: filePath, pageNumber: pageNumber))
            } else if call.method == "getNumberOfPages" {
                guard let arguments = call.arguments as? [String: Any],
                      let filePath = arguments["filePath"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                    return
                }
                result(self.getNumberOfPages(filePath: filePath))
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func getNumberOfPages(filePath: String) -> String? {
        // Verify the file exists at the given path
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: filePath) else {
            return nil
        }

        // Open the PDF document using PDFKit
        if let sourcePDFDocument = PDFDocument(url: URL(fileURLWithPath: filePath)) {
            let numberOfPages = sourcePDFDocument.pageCount
            let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)

            guard let temporaryDirectory = paths.first else {
                return nil
            }

            let filePathAndDirectory = temporaryDirectory.appendingPathComponent(kDirectory)
            
            do {
                // Clear cache folder
                if FileManager.default.fileExists(atPath: filePathAndDirectory.path) {
                    print("[FlutterPluginPDFViewer] Removing old documents cache")
                    try FileManager.default.removeItem(atPath: filePathAndDirectory.path)
                }

                try FileManager.default.createDirectory(atPath: filePathAndDirectory.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                print("Error: \(error.localizedDescription)")
                return nil
            }

            kFileName = UUID().uuidString
            print("[FlutterPluginPdfViewer] File has \(numberOfPages) pages")
            return "\(numberOfPages)"
        }

        return nil
    }

    func getPage(filePath: String, pageNumber: Int) -> String? {
        // Verify the file exists at the given path
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: filePath) else {
            return nil
        }

        do {
        // Open the PDF document using PDFDocument
            if let sourcePDFDocument = PDFDocument(url: URL(fileURLWithPath: filePath)) {
                let numberOfPages = sourcePDFDocument.pageCount
                let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
                
                guard let temporaryDirectory = paths.first,
                      pageNumber <= numberOfPages else {
                    return nil
                }
                
                let filePathAndDirectory = temporaryDirectory.appendingPathComponent(kDirectory)
                
                do {
                    // Clear cache folder
                    if FileManager.default.fileExists(atPath: filePathAndDirectory.path) {
                        print("[FlutterPluginPDFViewer] Removing old documents cache")
                        try FileManager.default.removeItem(atPath: filePathAndDirectory.path)
                    }
                    
                    try FileManager.default.createDirectory(atPath: filePathAndDirectory.path,
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)
                } catch {
                    print("Create directory error: \(error.localizedDescription)")
                    return nil
                }
                
                var kFileName = UUID().uuidString
                print("[FlutterPluginPdfViewer] File has \(numberOfPages) pages")
                
                if let sourcePDFPage = sourcePDFDocument.page(at: pageNumber-1) {
                    let relativeOutputFilePath = "\(kDirectory)/\(kFileName)-\(pageNumber).png"
                    let imageFilePath = temporaryDirectory.appendingPathComponent(relativeOutputFilePath)
                    var sourceRect = sourcePDFPage.bounds(for: .mediaBox)
                    if (sourcePDFPage is PDFPage)
                    {
                        
                    }
                    
                    
                    
                    
                      
                    var cgImage = sourcePDFPage.thumbnail(of: NSSize(width: sourceRect.width, height: sourceRect.height), for: .mediaBox)
              
                    
                          
                     // Create a PNG representation and save it to a file
                     try cgImage.tiffRepresentation?.write(to: imageFilePath)
                     return imageFilePath.path
                            
                        
                    
                }
            }
        } catch {
            print("Error creating PDFDocument: \(error.localizedDescription)")
        }

               return nil
           }
}
