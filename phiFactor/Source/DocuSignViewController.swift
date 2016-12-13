//
//  DocuSignViewController.swift
//  PhiFactor
//
//  Created by Shajakhan on 01/12/16.
//  Copyright © 2016 Hubino. All rights reserved.
//

import UIKit
import DocuSignESign
import Alamofire


class DocuSignViewController: UIViewController, UIWebViewDelegate, AppInactiveDelegate {

//    var patientPointer : UnsafeMutablePointer<patientProperties>?
    var accountId = ""
    var returnURL = "https://www.google.com"
//    var signedDocumentURL : NSURL?
//    var certificateURL : NSURL?
    var envelopeViewURL : NSURL?
    var isShowingAlert = false
    var blurEffectView = UIView()

    var envelopesAPI : DSEnvelopesApi?
//    var envelopeID : String?
    
    @IBOutlet weak var docuSignWebView: UIWebView!
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var docuSignWebViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var alertView: UIView!
    @IBOutlet weak var alertMessageLabel: UILabel!
    @IBOutlet var launguageAlertView: UIView!
    @IBOutlet weak var refreshButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        APP_DELEGATE?.inactiveDelegate = self
        
        if patient.document?.status == docuSignStatus.delivered || patient.document?.status == docuSignStatus.Sent {
            self.docuSignlogin({ (apiClient) in
                let recipientRequest = DSRecipientViewRequest()
                recipientRequest.returnUrl = self.returnURL
                recipientRequest.email = patient.email != nil && patient.email != "" ?  patient.email :  DocuSignRecipientMailID
                recipientRequest.userName = patient.name
                recipientRequest.authenticationMethod = "email"
                recipientRequest.clientUserId = patient.IDonDB
                
                self.envelopesAPI?.createRecipientViewWithCompletionBlock(self.accountId, envelopeId: patient.document?.envelopeID, recipientViewRequest: recipientRequest, completionHandler: { (recipientViewURL, error) in
                    if recipientViewURL != nil {
                        self.activityImageView.hidden = true
                        self.refreshButton.hidden = false
                        self.envelopeViewURL = NSURL(string: recipientViewURL.url)
                        if self.envelopeViewURL != nil {
                            self.docuSignWebView.loadRequest(NSURLRequest(URL: self.envelopeViewURL!))
                        }
                    }
                    else {
                        self.activityImageView.hidden = true
                    }
                })
            })
        }
        else {
            self.showlaunguageAlertView()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = request.URL?.host
        if urlString == self.returnURL.stringByReplacingOccurrencesOfString("https://", withString: "") {
            self.docuSignlogin({ (apiClient) in
                self.envelopesAPI?.getEnvelopeWithCompletionBlock(self.accountId, envelopeId: patient.document?.envelopeID, completionHandler: { (envelope, error) in
                    if envelope.status == "completed" {
                        self.envelopesAPI?.getDocumentWithCompletionBlock(self.accountId, envelopeId: patient.document?.envelopeID, documentId: "1", completionHandler: { (documentURL, error) in
                            if documentURL != nil {
                                patient.document?.signedDocumentURL = documentURL
                                self.envelopesAPI?.getDocumentWithCompletionBlock(self.accountId, envelopeId: patient.document?.envelopeID, documentId: "certificate", completionHandler: { (documentURL, error) in
                                    if documentURL != nil {
                                        patient.document?.certificateURL = documentURL
                                        print(patient.document?.certificateURL)
                                        print(patient.document?.signedDocumentURL)
                                        patient.document?.status = docuSignStatus.completed
                                        let data = NSData(contentsOfURL: (patient.document?.signedDocumentURL!)!)
                                        self.showAlert(docuSignComplitionAlertText)
                                        self.docuSignWebView.loadData(data!, MIMEType: "application/pdf", textEncodingName: "", baseURL: (patient.document?.signedDocumentURL!.URLByDeletingLastPathComponent!)!)
                                        //                                                self.docuSignWebView.loadRequest(NSURLRequest(URL: docURL))
                                        self.docuSignWebViewBottomConstraint.constant = 90
                                        let cameraModel = PFCameraScreenModel()
                                        let signedLink = cameraModel.uploadDocument((patient.document?.signedDocumentURL)!.absoluteString!.stringByReplacingOccurrencesOfString("file://", withString: ""), patientId: patient.IDonDB!)
                                        let certificateLink = cameraModel.uploadDocument((patient.document?.certificateURL)!.absoluteString!.stringByReplacingOccurrencesOfString("file://", withString: ""), patientId: patient.IDonDB!)
                                        self.updatePatientDocumentInfoOnPortal(patient.IDonDB!
                                        , documentURL: signedLink, certificateURL: certificateLink, envelopeID: (patient.document?.envelopeID)!, isDocuSign: true) { (isSucceed) in
                                            if isSucceed {
                                                print("DocuSign Document uploaded")
                                            }
                                            else {
                                                print("DocuSign Document failed")
                                            }
                                        }
                                    }
                                    else {
                                        self.activityImageView.hidden = true
                                        self.showAlert(docuSignErrorAlertText)
                                    }
                                })
                            }
                            else {
                                self.activityImageView.hidden = true
                                self.showAlert(docuSignErrorAlertText)
                            }
                        })
                        self.refreshButton.hidden = true
                    }
                    else if envelope.status == "declined" && self.refreshButton.enabled == true{
                        self.activityImageView.hidden = true
                        patient.document?.status = docuSignStatus.declined
                        self.navigationController?.popViewControllerAnimated(false)
                    }
                    else if envelope.status == "delivered"{
                        patient.document?.status = docuSignStatus.delivered
                        let cameraView = PFGlobalConstants.getViewController("PFCameraviewcontrollerscreen") as! PFCameraviewcontrollerscreen
                        self.navigationController?.pushViewController(cameraView, animated: false)
                    }
                })
            })
            return false
        }

     return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.activityImageView.hidden = false
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.activityImageView.hidden = true
        self.refreshButton.enabled = true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        self.activityImageView.hidden = true
    }
    
    /**
     Displaying the view as a video player which presents the user to how to take a video.
     
     - parameter sender: howtotakevideo information button from interface.
     */
    
    @IBAction func howtotakevideo(sender: AnyObject) {
        print("DocuSignViewController howtotakevideo begin")
        PFGlobalConstants.sendEventWithCatogory("UI", action: "buttonPressed", label: "HowToTakeVideo", value: nil)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("VideoPreviewView") as! VideoPreviewView
        nextViewController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        let path2 = NSBundle.mainBundle().pathForResource("fullVideo", ofType: "mp4")
        let url = NSURL.fileURLWithPath(path2!)
        nextViewController.itemUrl = url
        nextViewController.isPresentedView = true
        self.presentViewController(nextViewController, animated: true, completion: nil)
        print("DocuSignViewController howtotakevideo end")
    }
    @IBAction func startVideoAction(sender: AnyObject) {
        let documentPath = String(format: "\(NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0])/maimagepickercontollerfinalimage.jpg")
        let documentData = NSData(contentsOfURL: (patient.document?.signedDocumentURL)!)
        documentData?.writeToFile(documentPath, atomically: true)
        
        let cameraView = PFGlobalConstants.getViewController("PFCameraviewcontrollerscreen") as! PFCameraviewcontrollerscreen
        self.navigationController?.pushViewController(cameraView, animated: false)
    }
    
    @IBAction func refreshAction(sender: AnyObject) {
        if self.envelopeViewURL != nil && self.refreshButton.enabled == true{
            self.refreshButton.enabled = false
            self.docuSignlogin({ (apiClient) in
                let recipientRequest = DSRecipientViewRequest()
                recipientRequest.returnUrl = self.returnURL
                recipientRequest.email = patient.email != nil && patient.email != "" ?  patient.email :  DocuSignRecipientMailID
                recipientRequest.userName = patient.name
                recipientRequest.authenticationMethod = "email"
                recipientRequest.clientUserId = patient.IDonDB
                
                self.envelopesAPI?.createRecipientViewWithCompletionBlock(self.accountId, envelopeId: patient.document?.envelopeID, recipientViewRequest: recipientRequest, completionHandler: { (recipientViewURL, error) in
                    if recipientViewURL != nil {
                        self.activityImageView.hidden = true
                        self.refreshButton.hidden = false
                        self.envelopeViewURL = NSURL(string: recipientViewURL.url)
                        if self.envelopeViewURL != nil {
                            self.docuSignWebView.loadRequest(NSURLRequest(URL: self.envelopeViewURL!))
                        }
                    }
                    else {
                        self.activityImageView.hidden = true
                    }
                })
            })
        }
    }
    func remainingTime(time: String) {
        if !isShowingAlert {
            self.alertMessageLabel.text = time
            var uploadframe: CGRect!
            uploadframe=alertView.frame
            uploadframe.origin.x=self.view.frame.origin.x
            uploadframe.size.width=self.view.frame.size.width
            uploadframe.size.height=100
            uploadframe.origin.y=self.view.frame.origin.y-50
            self.alertView.frame=uploadframe
            self.view.addSubview(alertView)
            self.alertMessageLabel.text = time
            var setresize: CGRect!
            setresize=self.alertView.frame
            setresize.origin.x=self.alertView.frame.origin.x
            setresize.origin.y=0
            setresize.size.width=self.view.frame.size.width
            setresize.size.height=100
            isShowingAlert = true
            
            UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.alertView.frame=setresize
                }, completion: nil)
        }
        else {
            self.alertMessageLabel.text = time
        }
        
    }
    func hideInactiveAlert() {
        var setresizenormal: CGRect!
        setresizenormal=self.alertView.frame
        setresizenormal.origin.x=self.alertView.frame.origin.x
        setresizenormal.origin.y=0-self.alertView.frame.size.height
        setresizenormal.size.width=self.view.frame.size.width
        setresizenormal.size.height=100
        UIView.animateWithDuration(0.30, delay: 3.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.alertView.frame=setresizenormal
        }) { (completed) in
            self.isShowingAlert = false
        }
    }
    func showAlert(message : String) {
        if !isShowingAlert {
            self.alertMessageLabel.text = message
            var uploadframe: CGRect!
            uploadframe=alertView.frame
            uploadframe.origin.x=self.view.frame.origin.x
            uploadframe.size.width=self.view.frame.size.width
            uploadframe.size.height=100
            uploadframe.origin.y=self.view.frame.origin.y-50
            self.alertView.frame=uploadframe
            self.view.addSubview(alertView)
            self.alertMessageLabel.text = message
            var setresize: CGRect!
            setresize=self.alertView.frame
            setresize.origin.x=self.alertView.frame.origin.x
            setresize.origin.y=0
            setresize.size.width=self.view.frame.size.width
            setresize.size.height=100
            isShowingAlert = true
            UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { 
                self.alertView.frame=setresize
                }, completion: { (completed) in
                    var setresizenormal: CGRect!
                    setresizenormal=self.alertView.frame
                    setresizenormal.origin.x=self.alertView.frame.origin.x
                    setresizenormal.origin.y=0-self.alertView.frame.size.height
                    setresizenormal.size.width=self.view.frame.size.width
                    setresizenormal.size.height=100
                    UIView.animateWithDuration(0.30, delay: 3.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        self.alertView.frame=setresizenormal
                    }) { (completed) in
                        self.isShowingAlert = false
                    }
            })
        }
        else {
            self.alertMessageLabel.text = message
        }
    }
    func docuSignlogin(complition : (apiClient: DSApiClient) ->()){
        let apiClient = DSApiClient(baseURL: NSURL(string: DocuSignHostURL)!)
        let authApi = DSAuthenticationApi(apiClient: apiClient)
        authApi.addHeader(DocuSignAuth, forKey: DocuSignAuthHeader)
        let imageData = NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("loading", withExtension: "gif")!)
        self.activityImageView.image = UIImage.gifWithData(imageData!)
        
        self.activityImageView.hidden = false
        authApi.loginWithCompletionBlock { (loginInformation, error) in
            if loginInformation != nil {
                // The output below is limited by 1 KB.
                // Please Sign Up (Free!) to remove this limitation.
                
                let loginAccount = loginInformation.loginAccounts[0]
                self.accountId = loginAccount.accountId
                // Update ApiCLient with the new base url from login call
                var newHost : String = loginAccount.baseUrl
                if let newHostArray : [String] = newHost.componentsSeparatedByString("/v2")
                {
                    if newHostArray.count != 0 {
                        newHost = newHostArray[0]
                    }
                }
                let apiClient = DSApiClient(baseURL: NSURL(string: newHost)!)
                // instantiate a new envelope
                self.envelopesAPI = DSEnvelopesApi(apiClient: apiClient)
                self.envelopesAPI?.addHeader(DocuSignAuth, forKey: DocuSignAuthHeader)
                complition(apiClient: apiClient)
            }
            else {
                self.activityImageView.hidden = true
            }
        }
    }
    func  removeLaunguageAlert() {
        var setresizenormal: CGRect!
        setresizenormal=self.launguageAlertView.frame
        setresizenormal.origin.x=self.launguageAlertView.frame.origin.x
        setresizenormal.origin.y=self.launguageAlertView.frame.size.height
        setresizenormal.size.width=self.view.frame.size.width
        setresizenormal.size.height=self.launguageAlertView.frame.size.height
        UIView.animateWithDuration(0.30, delay: 0, options: .CurveEaseInOut, animations: {
            self.launguageAlertView.frame=setresizenormal
        }) { (completed) in
            self.blurEffectView.removeFromSuperview()
        }
    }
    
    /**
     Showing the confirmation alert from top while back button is pressed for exit the current session or not.
     */
    func showlaunguageAlertView() {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        //        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        launguageAlertView.frame.size.width=self.view.frame.size.width
        launguageAlertView.frame.size.height=self.view.frame.size.height
        launguageAlertView.frame.origin.x=0
        launguageAlertView.frame.origin.y=self.view.frame.size.height
        self.view.addSubview(launguageAlertView)
        var setframe=launguageAlertView.frame
        setframe.size.width=launguageAlertView.frame.size.width
        setframe.size.height=launguageAlertView.frame.size.height
        setframe.origin.y=0
        setframe.origin.x=0
        UIView.animateWithDuration(0.30, delay: 0, options: UIViewAnimationOptions.TransitionCurlUp, animations: {
            self.launguageAlertView.frame=setframe
            }, completion: nil)
    }
    func createNewEnvelope(template: String) {
        self.docuSignlogin { (apiClient) in
            // create envelope with single document, single signer and one signature tab
            let envelopeDefinition = DSEnvelopeDefinition()
            envelopeDefinition.emailSubject = "Phifactor Agreement."
            // to use a template we must reference the correct template id
            envelopeDefinition.templateId = template
            // assign recipient to template role by setting name, email, and role name.  Note that the
            // template role name must match the placeholder role name saved in your account template.
            envelopeDefinition.status = "sent"
            let templatesApi = DSTemplatesApi(apiClient: apiClient)
            templatesApi.addHeader(DocuSignAuth, forKey: DocuSignAuthHeader)
            templatesApi.getWithCompletionBlock(self.accountId, templateId: template, completionHandler: { (envelopeTemplate, error) in
                if envelopeTemplate != nil {
                    envelopeDefinition.documents = envelopeTemplate.documents
                    self.envelopesAPI?.createEnvelopeWithCompletionBlock(self.accountId, envelopeDefinition: envelopeDefinition, completionHandler: { (envelopeSummary, error) in
                        if envelopeSummary != nil {
                            patient.document?.envelopeID = envelopeSummary.envelopeId
                            let signer = DSSigner()
                            signer.email = patient.email != nil && patient.email != "" ?  patient.email :  DocuSignRecipientMailID
                            signer.name = patient.name
                            signer.recipientId = "1"
                            signer.clientUserId = patient.IDonDB
                            signer.signInEachLocation = "false"
                            signer.defaultRecipient = "true"
                            let recipients = DSRecipients()
                            recipients.recipientCount = "1"
                            recipients.signers = NSArray(object: signer) as! [DSSigner]
                            self.envelopesAPI?.updateRecipientsWithCompletionBlock(self.accountId, envelopeId: patient.document?.envelopeID, recipients: recipients, completionHandler: { (recipientsSummary, error) in
                                if recipientsSummary != nil {
                                    let recipientRequest = DSRecipientViewRequest()
                                    recipientRequest.returnUrl = self.returnURL
                                    recipientRequest.email = patient.email != nil && patient.email != "" ?  patient.email :  DocuSignRecipientMailID
                                    recipientRequest.userName = patient.name
                                    recipientRequest.authenticationMethod = "email"
                                    recipientRequest.clientUserId = patient.IDonDB
                                    
                                    self.envelopesAPI?.createRecipientViewWithCompletionBlock(self.accountId, envelopeId: patient.document?.envelopeID, recipientViewRequest: recipientRequest, completionHandler: { (recipientViewURL, error) in
                                        if recipientViewURL != nil {
                                            self.activityImageView.hidden = true
                                            self.refreshButton.hidden = false
                                            self.envelopeViewURL = NSURL(string: recipientViewURL.url)
                                            if self.envelopeViewURL != nil {
                                                self.docuSignWebView.loadRequest(NSURLRequest(URL: self.envelopeViewURL!))
                                            }
                                        }
                                        else {
                                            self.activityImageView.hidden = true
                                            self.showAlert(docuSignErrorAlertText)
                                        }
                                    })
                                }
                                else {
                                    self.activityImageView.hidden = true
                                    self.showAlert(docuSignErrorAlertText)
                                }
                            })
                        }
                        else {
                            self.activityImageView.hidden = true
                            self.showAlert(docuSignErrorAlertText)
                        }
                    })
                }
                else {
                    self.activityImageView.hidden = true
                    self.showAlert(docuSignErrorAlertText)
                }
            })
        }
    }
    
    /**
     Update patient media details to portal.
     */
    func updatePatientDocumentInfoOnPortal(patientId: String, documentURL: String, certificateURL: String = "", documentID: String = "", envelopeID: String = "", isDocuSign: Bool, complition: (isSucceed: Bool)->()) {
        print("PatientScreen getRefreshToken begin")
        let defaults = NSUserDefaults.standardUserDefaults()
        var access_token: String!
        var token_type: String!
        access_token = defaults.stringForKey("access_token")
        token_type = defaults.stringForKey("token_type")
        PFGlobalConstants.sendEventWithCatogory("background", action: "functionCall", label: "updatePatientMediaDetailsOnPortal", value: nil)
        requestString = "\(baseURL)/document_info_update?Authorization=\(token_type)&access_token=\(access_token)"
        print(requestString)
        url1 = NSURL(string: requestString as String)!
        urlRequest = NSMutableURLRequest(URL: url1)
        urlRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let cameraModel = PFCameraScreenModel()
        cameraModel.getRequestParameterForUpdatePatientDocumentInfo(patientId, documentURL: documentURL, certificateURL: certificateURL, documentID: documentID, envelopeID: envelopeID, isDocuSign: isDocuSign)
        Alamofire.request(urlRequest)
            .responseJSON { response in
                switch response.result {
                case .Failure( let error):
                    print(error)
                    complition(isSucceed: false)
                case .Success(let responseObject):
                    print(responseObject)
                    complition(isSucceed: true)
                    //                    let response = responseObject as! NSDictionary
                }
                print("PatientScreen getRefreshToken end")
        }
    }
    @IBAction func englishLanguageAction(sender: AnyObject) {
        self.removeLaunguageAlert()
        self.createNewEnvelope(DocuSignEnglishTemplateID)
    }
    @IBAction func spanishLanguageAction(sender: AnyObject) {
        self.removeLaunguageAlert()
        self.createNewEnvelope(DocuSignSpanishTemplateID)
    }
}
