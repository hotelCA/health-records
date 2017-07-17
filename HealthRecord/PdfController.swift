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

    var pdfFilename: String!

    override init() {
        super.init()

        let pageFrame = CGRect(x: 0.0, y: 0.0, width: A4PageWidth, height: A4PageHeight)

        self.setValue(NSValue(cgRect: pageFrame), forKey: "paperRect")

        self.setValue(NSValue(cgRect: pageFrame.insetBy(dx: 10.0, dy: 10.0)), forKey: "printableRect")
    }

    func exportHTMLContentToPDF(htmlContent: String) {

        let printFormatter = UIMarkupTextPrintFormatter(markupText: htmlContent)
        addPrintFormatter(printFormatter, startingAtPageAt: 0)

        let pdfData = drawPDFUsingPrintPageRenderer(pdfController: self)

        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

        let pdfFilename = documentDirectory.appendingPathComponent("health_records.pdf")
        pdfData!.write(to: pdfFilename, atomically: true)
        
        print(pdfFilename)
    }

    func drawPDFUsingPrintPageRenderer(pdfController: PdfController) -> NSData! {

        let data = NSMutableData()

        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)

        UIGraphicsBeginPDFPage()

        pdfController.drawPage(at: 0, in: UIGraphicsGetPDFContextBounds())

        UIGraphicsEndPDFContext()
        
        return data
    }
}
