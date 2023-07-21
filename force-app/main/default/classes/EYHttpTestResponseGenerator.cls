@isTest
global class EYHttpTestResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"billingDate":"2021-07-23T00:00:00","billingDocumentNumber":"27TI1285","processingDate":"2021-07-23T20:30:07.8015326+05:30","registrationStatus":"Yes","posTable":"POS_Matrix","posColumn":"State of Bill to Party Location","posCity":"MUMBAI","posState":"Maharashtra","posStateCode":"27","lospTable":"POS_Matrix","lospColumn":"State of Bill to Party Location","lospCity":"MUMBAI","lospState":"Maharashtra","lospStateCode":"27","supplyType":"TAX","irnNumber":"be2f418c880351506bf8d23058a98d83ba831a1da83ec5d0d3b4db65a34644d2","signedQRCode":"eyJhbGciOiJSUzI1NiIsImtpZCI6IkVEQzU3REUxMzU4QjMwMEJBOUY3OTM0MEE2Njk2ODMxRjNDODUwNDciLCJ0eXAiOiJKV1QiLCJ4NXQiOiI3Y1Y5NFRXTE1BdXA5NU5BcG1sb01mUElVRWMifQ.eyJkYXRhIjoie1wiU2VsbGVyR3N0aW5cIjpcIjI3QUFBQ0IyMzUwSDFaMlwiLFwiQnV5ZXJHc3RpblwiOlwiMjdBQUNDVjM5NjFHMVo3XCIsXCJEb2NOb1wiOlwiMjdUSTEyODVcIixcIkRvY1R5cFwiOlwiSU5WXCIsXCJEb2NEdFwiOlwiMjMvMDcvMjAyMVwiLFwiVG90SW52VmFsXCI6ODkzOTYuOCxcIkl0ZW1DbnRcIjozLFwiTWFpbkhzbkNvZGVcIjpcIjk5Njc5OVwiLFwiSXJuXCI6XCJiZTJmNDE4Yzg4MDM1MTUwNmJmOGQyMzA1OGE5OGQ4M2JhODMxYTFkYTgzZWM1ZDBkM2I0ZGI2NWEzNDY0NGQyXCIsXCJJcm5EdFwiOlwiMjAyMS0wNy0yMyAyMDozMjo0OVwifSIsImlzcyI6Ik5JQyJ9.muPqOjXrBGp-1YREob9Q4ElDGXOzMUPvWp18r2mwkel6zWr91TsnQpsxllP7knPXJtUx2jujdc6ixXWraTxznlperg67rek9C2Nf20lKW1N6SY4uoAMhJT80toxT-5o4JOYiORN3YQwkpGYxEps3627Kktqo6gejzaN1JLham1BQXoWBRjuefn1T6S6UifsBMRHxCq_JSAwAr6KXDON_tlV0yRkqzVnEoigTngvvbgwJshq2GgqnbbCPNk22XcrQUlssQ8P2ItM2f3aBMmlpM-salDQOrBXRFOULIxTQcMdtmN_cFKJWzl2enNAVAedq3BoFuk_qsgzibbDwhHJoKA","ackNumber":"122110055527919","ackDateTime":"2021-07-23 20:32:49","taxEngineErrorCode":null,"taxEngineErrorMessage":null,"digiGSTErrorCode":null,"digiGSTErrorMessage":null,"lineItems":[{"itemNumber":"1","tax":0,"totalItemValue":29806.800000000003,"materialDescription":"FREIGHT CHARGES","natureOfService":"FREIGHT CHARGES","sacApplicable":"996531","taxApplicablePercentage":0.18,"taxCategory":"CGST/SGST","taxCalculated":4546.8,"taxCalculatedINR":4546.8,"igstPercentage":0,"cgstPercentage":0.09,"sgstPercentage":0.09,"igst":0,"cgst":2273.4,"sgst":2273.4,"igsT_INR":0,"cgsT_INR":2273.4,"sgsT_INR":2273.4},{"itemNumber":"2","tax":0,"totalItemValue":59000,"materialDescription":"LIABILITY CHARGES","natureOfService":"LIABILITY CHARGES","sacApplicable":"996799","taxApplicablePercentage":0.18,"taxCategory":"CGST/SGST","taxCalculated":9000,"taxCalculatedINR":9000,"igstPercentage":0,"cgstPercentage":0.09,"sgstPercentage":0.09,"igst":0,"cgst":4500,"sgst":4500,"igsT_INR":0,"cgsT_INR":4500,"sgsT_INR":4500},{"itemNumber":"3","tax":0,"totalItemValue":590,"materialDescription":"OFFLINE CHARGES","natureOfService":"OFFLINE CHARGES","sacApplicable":"996792","taxApplicablePercentage":0.18,"taxCategory":"CGST/SGST","taxCalculated":90,"taxCalculatedINR":90,"igstPercentage":0,"cgstPercentage":0.09,"sgstPercentage":0.09,"igst":0,"cgst":45,"sgst":45,"igsT_INR":0,"cgsT_INR":45,"sgsT_INR":45}]}');
        res.setStatusCode(200);
        return res;
    }
}