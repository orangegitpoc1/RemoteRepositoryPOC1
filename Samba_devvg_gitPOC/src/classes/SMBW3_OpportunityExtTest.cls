@isTest
public class SMBW3_OpportunityExtTest{
    
    static testMethod void testNotes(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeghijkl@testorg.com', SMB_Bypass_VR__c=true, PAD_BypassTrigger__c=';SMBW3_Opportunity_TR009_OppSplit_TRG;');
        System.runAs(u){
            TestDataCreation.createSplitcommission(1, 'Commission');
            TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
            TestDataCreation.createSplitfinance(1, 'Finance');
            TestDataCreation.createcustomsetting_profile();
            Account acc=TestDataCreation.createAccounts(1)[0];
            Account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
            Opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0];
            TestDataCreation.createNotes(1, opp.Id);
            Id attachId = TestDataCreation.createAttachments(1, opp.Id)[0].Id;
            TestDataCreation.createMasterAttachApprovals(1, attachId, true);
            PageReference pgRef = Page.SMBW3_Opportunity_Attachment_VFP;
            pgRef.getParameters().put('id', opp.Id);
            Test.setCurrentPage(pgRef);
            System.assertEquals(1, new SMBW3_OpportunityExt(new ApexPages.StandardController(opp)).getNotes().size());
        }
    }
    
    static testMethod void testNavigateBack(){
        TestDataCreation.createSplitcommission(1, 'Commission');
        TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
        TestDataCreation.createSplitfinance(1, 'Finance');
        TestDataCreation.createcustomsetting_profile();
        Account acc=TestDataCreation.createAccounts(1)[0];
        Account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
        Opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0];
        Id attachId = TestDataCreation.createAttachments(1, opp.Id)[0].Id;
        TestDataCreation.createMasterAttachApprovals(1, attachId, false);
        PageReference pgRef = Page.SMBW3_Opportunity_Attachment_VFP;
        pgRef.getParameters().put('id', opp.Id);
        Test.setCurrentPage(pgRef);
        System.assertEquals('/'+opp.Id, new SMBW3_OpportunityExt(new ApexPages.StandardController(opp)).navigateBack().getUrl());
    }
    
    static testMethod void testDelAttachAndNote(){
        TestDataCreation.createSplitcommission(1, 'Commission');
        TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
        TestDataCreation.createSplitfinance(1, 'Finance');
        TestDataCreation.createcustomsetting_profile();
        Account acc=TestDataCreation.createAccounts(1)[0];
        Account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
        Opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0];
        SMBW3_OpportunityExt obj = new SMBW3_OpportunityExt(new ApexPages.StandardController(opp));
        obj.delId = opp.Id;
        obj.delAttachAndNote();
        System.assertEquals(0, [SELECT Id FROM Opportunity WHERE Id =: opp.Id].size());
    }
    
    static testMethod void testAttachmentWrapperSorting(){
        TestDataCreation.createSplitcommission(1, 'Commission');
        TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
        TestDataCreation.createSplitfinance(1, 'Finance');
        Account acc=TestDataCreation.createAccounts(1)[0];
        Account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
        Opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0];
        List<Attachment> attchList = TestDataCreation.createAttachments(2, opp.Id);
        List<SMBW3_OpportunityExt.AttachmentWrapper> attachWrapList = new List<SMBW3_OpportunityExt.AttachmentWrapper>();
        attachWrapList.add(new SMBW3_OpportunityExt.AttachmentWrapper(attchList[0], null, ''));
        attachWrapList.add(new SMBW3_OpportunityExt.AttachmentWrapper(attchList[1], null, ''));
        attachWrapList.sort();
        System.assertEquals('Test0', attachWrapList[0].attach.Name);
        System.assertEquals('Test1', attachWrapList[1].attach.Name);        
    }

    static testMethod void testSaveDoc(){
        Id parentRoleId = TestDataCreation.createUserRoles(1, null)[0].Id;
        TestDataCreation.createUsers(1, System.Label.Sales_Operation_SAMBA, System.Label.User_Frequency_1day, parentRoleId);
        Id roleId = TestDataCreation.createUserRoles(1, parentRoleId)[0].Id;
        Id userId = TestDataCreation.createUsers(1, System.Label.Sales_User_SAMBA, System.Label.User_Frequency_1day, roleId)[0].Id;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='SMBW3_Opportunity_TR009_OppSplit_TRG;SMB_Opportunity_UpdateGAMField', UserRoleId=roleId);
        List<UserRole> obsGlobalList=[select id, name, developerName from UserRole where developerName=:Label.SMBW3_CL038_OBSGlobalRole];
        UserRole obsGlobal;
        if (obsGlobalList.isEmpty()){
            obsGlobal = new UserRole(Name=Label.SMBW3_CL038_OBSGlobalRole, developerName=Label.SMBW3_CL038_OBSGlobalRole);
            insert obsGlobal;
        } else {
            obsGlobal=obsGlobalList[0];
        }
        
        //kd: 9th Oct 2015
        Id userOBSGlobalSalesOppId = TestDataCreation.createUsersWithUsernamePrefixAlias(1, System.Label.Sales_Operation_SAMBA, System.Label.User_Frequency_1day, obsGlobal.id, 'TestSalesOpp1', 'SO1')[0].Id;
        Id roleId2 = TestDataCreation.createUserRoles(1, obsGlobal.id)[0].Id;
        Id userOBSGlobalSalesUserId = TestDataCreation.createUsersWithUsernamePrefixAlias(1, System.Label.Sales_User_SAMBA, System.Label.User_Frequency_1day, roleId2, 'TestSalesUser1', 'SU1')[0].Id;
        
        System.runAs(u){
            TestDataCreation.createSplitcommission(1, 'Commission');
            TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
            TestDataCreation.createSplitfinance(1, 'Finance');
            account acc=TestDataCreation.createAccounts(1)[0];
            System.assertEquals(acc.name,'Test0');
            account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
            opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0];
            opp.GAM_type__c='Standard GAM';
            Id oppId=opp.id;
            TestDataCreation.createOpportunityTeamMember(1, oppId, userId);            

            //kd: Added on 9th Oct 2015:
            TestDataCreation.createNotes(1, oppId);
            Attachment attach1 = TestDataCreation.createAttachments(1, oppId)[0];
            Id attachId = attach1.id;
            TestDataCreation.createcustomsetting_profile();
            PageReference pgRef = Page.SMBW3_Opportunity_Attachment_VFP;
            pgRef.getParameters().put('id', oppId);
            Test.setCurrentPage(pgRef);
            SMBW3_OpportunityExt obj = new SMBW3_OpportunityExt(new ApexPages.StandardController(opp));
            obj.myfile=attach1;
            obj.sendForApproval=true;
            
            Test.startTest();
            obj.saveDoc();
            List<Attachment_Approval__c> attApp=[select id, name, approve__c, reject__c, Rejection_Reason__c, Approval_Reason__c, Role_Attachment_Approval__r.Master_Attachment_Approval__r.Opportunity__c from Attachment_Approval__c where Role_Attachment_Approval__r.Master_Attachment_Approval__r.Opportunity__c=: opp.id];
            List<Role_Attachment_Approval__c> raApp= [select id, approve__c, reject__c, name, Master_Attachment_Approval__c from Role_Attachment_Approval__c where Master_Attachment_Approval__r.Opportunity__c=: opp.id];
            List<Master_Attachment_Approval__c> maApp= [select id, approve__c, reject__c, name, Opportunity__c from Master_Attachment_Approval__c where Opportunity__c=: opp.id];
            System.assertEquals(1, maApp.size());
            System.assertEquals(1, raApp.size());
            System.assertEquals(1, attApp.size());

            try {
                for (Master_Attachment_Approval__c aa: maApp){
                    aa.Reject__c=false;
                    aa.Approve__c=false;
                }
                update maApp; //Should fail at this update.
                System.assert(false, 'Failed: This user must not able to update Master_Attachment_Approval__c directly.');
            } catch (Exception e){
                
            }
            u.UserRoleId=obsGlobal.id;
            update u;

            for (Master_Attachment_Approval__c aa: maApp){
                aa.Reject__c=false;
                aa.Approve__c=false;
            }
            update maApp;
            
            for (Role_Attachment_Approval__c aa: raApp){
                aa.Reject__c=false;
                aa.Approve__c=false;
            }
            update raApp;
            
            for (Attachment_Approval__c aa: attApp){
                aa.Reject__c=true;
                aa.Rejection_Reason__c='test';
                aa.Approve__c=false;
            }
            update attApp;

            for (Attachment_Approval__c aa: attApp){
                aa.Reject__c=false;
                aa.Approve__c=true;
                aa.Approval_Reason__c='test';
            }
            update attApp;

        }
    }
    
}