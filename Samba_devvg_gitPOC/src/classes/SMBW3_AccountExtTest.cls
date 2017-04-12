@isTest
private class SMBW3_AccountExtTest {

    static testMethod void testNotes(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true);
        System.runAs(u){
            TestDataCreation.createSplitcommission(1, 'Commission');
            Account acc = TestDataCreation.createAccounts(1)[0];
            TestDataCreation.createNotes(1, acc.Id);
            TestDataCreation.createNotes(1, TestDataCreation.createOpportunitiesWithAccount(1, acc.Id)[0].Id);
            List<Attachment> attachId = TestDataCreation.createAttachments(2, TestDataCreation.createOpportunitiesWithAccount(1, acc.Id)[0].Id);
            TestDataCreation.createMasterAttachApprovals(1, attachId[0].Id, true);
            PageReference pgRef = Page.SMBW3_Account_Attachment_VFP;
            pgRef.getParameters().put('id', acc.Id);
            Test.setCurrentPage(pgRef);
            System.assertEquals(2, new SMBW3_AccountExt(new ApexPages.StandardController(acc)).getNotes().size());
        }
    }
    
    static testMethod void testNavigateBack(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true);
        System.runAs(u){
            Account acc = TestDataCreation.createAccounts(1)[0];
            PageReference pgRef = Page.SMBW3_Account_Attachment_VFP;
            pgRef.getParameters().put('id', acc.Id);
            Test.setCurrentPage(pgRef);
            System.assertEquals('/'+acc.Id, new SMBW3_AccountExt(new ApexPages.StandardController(acc)).navigateBack().getUrl());
        }
    }
    
    static testMethod void testDelAttachAndNote(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true);
        System.runAs(u){
            Note nt = TestDataCreation.createNotes(1, TestDataCreation.createAccounts(1)[0].Id)[0];
            SMBW3_AccountExt obj = new SMBW3_AccountExt(new ApexPages.StandardController(new Account()));
            obj.delId = nt.Id;
            obj.delAttachAndNote();
            System.assertEquals(0, [SELECT Id FROM Note WHERE Id =: nt.Id].size());
        }
    }
    
    static testMethod void testSaveDoc(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true);
        System.runAs(u){
            Account acc = TestDataCreation.createAccounts(1)[0];
            PageReference pgRef = Page.SMBW3_Account_Attachment_VFP;
            pgRef.getParameters().put('id', acc.Id);
            Test.setCurrentPage(pgRef);
            SMBW3_AccountExt obj = new SMBW3_AccountExt(new ApexPages.StandardController(acc));
            obj.myfile = new Attachment();
            obj.myfile.name = 'Test';
            obj.myfile.body = Blob.valueOf('Test');
            obj.saveDoc();
        }
    }
    
}