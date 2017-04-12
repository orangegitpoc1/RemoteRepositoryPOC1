@isTest
public class SMBW3_EmailToOppTeamMembersTest{
    
    static testMethod void testSendEmail(){
        Id parentRoleId = TestDataCreation.createUserRoles(1, null)[0].Id;
        TestDataCreation.createUsers(1, System.Label.Sales_Operation_SAMBA, System.Label.User_Frequency_1day, parentRoleId);
        
        Id roleId = TestDataCreation.createUserRoles(1, parentRoleId)[0].Id;
        Id userId = TestDataCreation.createUsers(1, System.Label.Sales_User_SAMBA, System.Label.User_Frequency_1day, roleId)[0].Id;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true);
        System.runAs(u){
           TestDataCreation.createSplitcommission(1, 'Commission');
           account acc=TestDataCreation.createAccounts(1)[0];
           System.assertEquals(acc.name,'Test0');
           account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
           opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0];
           Id oppId  = opp.Id;
            list<OpportunityTeamMember> OTM=TestDataCreation.createOpportunityTeamMember(1, oppId, userId);
            OTM[0].TeamMemberRole='Other';   
            Update OTM[0];         
            SMBW3_EmailToOppTeamMembers.sendEmail(new Set<Id>{oppId}, 'body', System.Label.User_Frequency_1day);
            delete OTM[0];
        }
    }
}