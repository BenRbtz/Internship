//
//  CSVFetch.swift
//  securePortal
//
//  Created by Ben Roberts on 25/07/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation
// import Alamofire

class TransactionSearchDownload {
    static var username, password: String?
    
    static func main(credentials: [String]){
        //Authenticates that the username and password has the correct privilege to upload/download the csv files
        if (credentials.count > 0){
            username = credentials[0];
            password = credentials[1];
        }
//        Authenticator.setDefault(MyStAuthenticator());
        //creates the request data for the ST download
        let request = "sitereferences=test_example80000&startdate=2011-01-01&optionalfields=errorcode&optionalfields=currencyiso3a&optionalfields=authcode&optionalfields=orderreference&optionalfields=paymenttypedescription&optionalfields=settlestatus&optionalfields=settlemainamount&optionalfields=settleduedate&optionalfields=customercountryiso2a";
        //downloads the string, this can then be written out to file, in this example it is simply printed out to stdout
        makeRequest(NSURL(string: "https://myst.securetrading.net/auto/transactions/transactionsearch")!, postData: request)
    }

    var responseData:NSMutableData?
    //POSTs the data to MyST
    static func makeRequest(url: NSURL,postData: String) {
//        Open a connection to the URL
//        HttpURLConnection con = (HttpURLConnection) url.openConnection();
//        let request1: NSMutableURLRequest = NSMutableURLRequest(URL: url)
////        let connection: NSURLConnection = NSURLConnection(request: request1, delegate: self, startImmediately: true)!
////        connection.start()
//        //Use post on all connections
//        con.setRequestMethod("POST");
//        request1.HTTPMethod = "POST"
//        //Allows us to post the data
//        con.setDoOutput(true);
//        con.connect();
//        OutputStreamWriter out = new OutputStreamWriter(con.getOutputStream());
//        //write the post to the outputstream
//        out.write(postData);
//        out.close();
//        
//        /* Read in the response from our server, you should receive the contents of the csv response file.
//         * However in the case of there being an error with the data you post a reason for this will be returned rather than the response file.
//         */
//        BufferedReader in = new BufferedReader( new InputStreamReader(con.getInputStream()));
//        String inputLine;
//        while ((inputLine= in.readLine()) != null)
//            print(inputLine);
//        in.close();
//        con.disconnect();
    }
    //Authorizes your user details with our Apache auth. The username must have the recurring update privilege in order to do the upload and download
//    struct MyStAuthenticator { //extends Authenticator
//        public override PasswordAuthentication getPasswordAuthentication(){
//        return new PasswordAuthentication(username, password.toCharArray());
//        }
//    }
//   func test() {//url: NSURL,postData: String
//        let user = "user"
//        let password = "password"
//        Alamofire.request(.POST, "http://httpbin.org/post", parameters: ["foo": "bar"])
//            .authenticate(user: user, password: password)
//            .validate()
//            .responseJSON { response in
//                switch response.result { // result of response serialization
//                case .Success:
//                    print("Validation Successful")
//                    print(response.request)  // original URL request
//                    print(response.response) // URL response
//                    print(response.data)     // server data
//         
//                    if let JSON = response.result.value {
//                        print("JSON: \(JSON)")
//                    }
//
//                case .Failure(let error):
//                    print(error)
//                }
//
//        }

//    }
}
