@isTest
private class OpportunityTeamMemberTriggerHandlerTest{

    static testMethod void afterInsertTest() {    
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeghijkl@testorg.com', SMB_Bypass_VR__c=true, PAD_BypassTrigger__c=';SMBW3_Opportunity_TR009_OppSplit_TRG;');
        System.runAs(u){
            TestDataCreation.createSplitcommission(1, 'Commission');
            Opportunity opp = TestDataCreation.createOpportunitiesWithAccount(1, TestDataCreation.createAccounts(1)[0].Id)[0];
            OpportunityTeamMember otm = TestDataCreation.createOpportunityTeamMember(1, opp.Id, u.Id)[0];
            OpportunityTeamMemberTriggerHandler obj = new OpportunityTeamMemberTriggerHandler();
            System.assertEquals(0, [SELECT Id FROM EntitySubscription Limit 1000].size());                
            obj.onAfterInsert(new List<OpportunityTeamMember>{otm}, new Map<ID, OpportunityTeamMember>{otm.Id => otm});
            System.assertEquals(1, [SELECT Id FROM EntitySubscription Limit 1000].size()); 
        }
    }
    
    static testMethod void afterDeleteTest() {    
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeghijkl@testorg.com', SMB_Bypass_VR__c=true, PAD_BypassTrigger__c=';SMBW3_Opportunity_TR009_OppSplit_TRG;');
        System.runAs(u){
            TestDataCreation.createSplitcommission(1, 'Commission');
            Opportunity opp = TestDataCreation.createOpportunitiesWithAccount(1, TestDataCreation.createAccounts(1)[0].Id)[0];
            TestDataCreation.createEntitySubscription(1, opp.Id, u.Id);
            OpportunityTeamMemberTriggerHandler obj = new OpportunityTeamMemberTriggerHandler();
            obj.onAfterDelete(new List<OpportunityTeamMember>(TestDataCreation.createOpportunityTeamMember(1, opp.Id, u.Id)), null);
            System.assertEquals(0, [SELECT Id FROM EntitySubscription Limit 1000].size()); 
        }
    }

}