//
//  PdfController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 7/15/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

class PdfController: UIPrintPageRenderer {

    let A4PageWidth: CGFloat = 595.2

    let A4PageHeight: CGFloat = 841.8

    let healthRecordsFilename = "health_records.pdf"

    override init() {
        super.init()

        let pageFrame = CGRect(x: 0.0, y: 0.0, width: A4PageWidth, height: A4PageHeight)

        self.setValue(NSValue(cgRect: pageFrame), forKey: "paperRect")

        self.setValue(NSValue(cgRect: pageFrame.insetBy(dx: 10.0, dy: 10.0)), forKey: "printableRect")
    }

    func exportHTMLContentToPDF(htmlContent: String) {

        let printFormatter = UIMarkupTextPrintFormatter(markupText: htmlContent)

        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.microseconds(1000000)) {

            self.addPrintFormatter(printFormatter, startingAtPageAt: 0)

            let pdfData = self.drawPDFUsingPrintPageRenderer(pdfController: self)

            let fileManager = FileManager.default
            let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let pdfFilename = documentDirectory.appendingPathComponent(self.healthRecordsFilename)

            print("\(htmlContent)")
            print("\(pdfFilename)")

            pdfData!.write(to: pdfFilename, atomically: true)
        }
    }

    func drawPDFUsingPrintPageRenderer(pdfController: UIPrintPageRenderer) -> NSData! {

        let data = NSMutableData()

        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)

        UIGraphicsBeginPDFPage()

        pdfController.drawPage(at: 0, in: UIGraphicsGetPDFContextBounds())

        UIGraphicsEndPDFContext()
        
        return data
    }
}
