@isTest
private class SendingEmailHelperTest {

    static testMethod void processEmailTest() {    
        try{
            SendingEmailHelper.processEmail(UserInfo.getUserId(), 'Subject_Test', 'Htmlbdy_Test', null, null);
            System.assert(true,'Running as Expected');
        }catch(Exception ex){
            System.assert(false,'Failed');        
        }
        
    }
}