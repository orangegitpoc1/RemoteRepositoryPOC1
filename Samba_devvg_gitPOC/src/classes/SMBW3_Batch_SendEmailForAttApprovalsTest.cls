@isTest
public class SMBW3_Batch_SendEmailForAttApprovalsTest{

    static testMethod void testSchedule(){
      
        
        Id parentRoleId = TestDataCreation.createUserRoles(1, null)[0].Id;
        TestDataCreation.createUsers(1, System.Label.Sales_Operation_SAMBA, System.Label.User_Frequency_1day, parentRoleId);
        
        Id roleId = TestDataCreation.createUserRoles(1, parentRoleId)[0].Id;
        //Id userId = TestDataCreation.createUsers(1, System.Label.Sales_User_SAMBA, System.Label.User_Frequency_1day, roleId)[0].Id;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
         User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='SMBW3_Opportunity_TR009_OppSplit_TRG',
        UserRoleId=roleId
        );
        
       List<UserRole> obsGlobalList=[select id, name, developerName from UserRole where developerName=:Label.SMBW3_CL038_OBSGlobalRole];
       UserRole obsGlobal;
       if (obsGlobalList.isEmpty()){
            obsGlobal = new UserRole(Name=Label.SMBW3_CL038_OBSGlobalRole, developerName=Label.SMBW3_CL038_OBSGlobalRole);
            insert obsGlobal;
        } else {
            obsGlobal=obsGlobalList[0];
        }
        
        
       System.runAs(u){
       Test.startTest();
            TestDataCreation.createSplitcommission(1, 'Commission');
            TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
            TestDataCreation.createSplitfinance(1, 'Finance');
            TestDataCreation.Createcustomsetting_profile();
           account acc=TestDataCreation.createAccounts(1)[0];
           System.assertEquals(acc.name,'Test0');
           account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
           opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0];
            opp.GAM_type__c='Standard GAM';
            Id oppId=opp.id;
Id userId = TestDataCreation.createUsers(1, System.Label.Sales_User_SAMBA, System.Label.User_Frequency_1day, roleId)[0].Id;
            TestDataCreation.createOpportunityTeamMember(1, oppId, userId);            
            
            //SMBW3_EmailToOppTeamMembers.sendEmail(new Set<Id>{oppId}, 'body', System.Label.User_Frequency_1day);

        //Opportunity opp = TestDataCreation.createOpportunities(1)[0];
        TestDataCreation.createNotes(1, oppId);
        Attachment attach1 = TestDataCreation.createAttachments(1, oppId)[0];
        Id attachId = attach1.id;
        //TestDataCreation.createMasterAttachApprovals(1, attachId, true);
        PageReference pgRef = Page.SMBW3_Opportunity_Attachment_VFP;
        pgRef.getParameters().put('id', oppId);
        Test.setCurrentPage(pgRef);
        SMBW3_OpportunityExt obj = new SMBW3_OpportunityExt(new ApexPages.StandardController(opp));
        obj.myfile=attach1;
        obj.sendForApproval=true;
        //obj.oppt=opp;
        obj.saveDoc();
        List<Attachment_Approval__c> attApp=[select id, name, Role_Attachment_Approval__r.Master_Attachment_Approval__r.Opportunity__c from Attachment_Approval__c where Role_Attachment_Approval__r.Master_Attachment_Approval__r.Opportunity__c=: opp.id];

List<Role_Attachment_Approval__c> raApp= [select id, approve__c, reject__c, name, Master_Attachment_Approval__c from Role_Attachment_Approval__c where Master_Attachment_Approval__r.Opportunity__c=: opp.id];
List<Master_Attachment_Approval__c> maApp= [select id, approve__c, reject__c, name, Opportunity__c from Master_Attachment_Approval__c where Opportunity__c=: opp.id];
        try {
            for (Master_Attachment_Approval__c aa: maApp){
                aa.reject__c=false;
                aa.Approve__c=false;
            }
            update maApp;
        } catch (Exception e){
            
        }
        u.UserRoleId=obsGlobal.id;
        update u;
        //obj.saveDoc();
        for (Master_Attachment_Approval__c aa: maApp){
            aa.reject__c=false;
            aa.Approve__c=true;
        }
        update maApp;
/*        
        for (Role_Attachment_Approval__c aa: raApp){
            aa.reject__c=false;
            aa.Approve__c=false;
        }
        update raApp;
        
        for (Attachment_Approval__c aa: attApp){
            aa.reject__c=true;
            aa.Rejection_Reason__c='test';
        }
        update attApp;

        
        for (Attachment_Approval__c aa: attApp){
            aa.reject__c=false;
            aa.Approve__c=true;
            aa.Approval_Reason__c='test';
        }
        update attApp;
*/      
       }
    

            String jobId = System.schedule('SMBW3_Batch_SendEmailForAttApprovalsTest', 
                             '0 0 12 1/1 * ?', new SMBW3_Batch_SendEmailForAttApprovals());
        Test.stopTest();
    }
    
}