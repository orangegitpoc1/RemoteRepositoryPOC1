@isTest
private class SMB_Chatter_HelperTest {

    static testMethod void createFeedListTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeghijkl@testorg.com', SMB_Bypass_VR__c=true, PAD_BypassTrigger__c=';SMBW3_Opportunity_TR009_OppSplit_TRG;');
        System.runAs(u){
            try{
                TestDataCreation.createSplitcommission(1, 'Commission');
                Opportunity opp = TestDataCreation.createOpportunities(1)[0];
                SMB_Chatter_Helper.createFeedList(opp.Id, u.Id, 'testing');
                System.assert(true, 'Running as Expected');
            }catch(Exception ex){
                System.assert(false, 'Failed');
            }
        }
    }
}