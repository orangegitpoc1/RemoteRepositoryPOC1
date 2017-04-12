/**
    About
    -----
    Description: This class is used to test SMBW2_UserAssignment_GlobalTeaming
    Created for: SAMBA Wave2
    Create date: Dec 2014
    
    Details
    -------
    This Class test the functionality of SMBW2_UserAssignment_GlobalTeaming_Test class.
    1. Test Method to update Contact's Account Type field SMB_Account_Type__c with Account RecodType Developer Name when RecordType is changed.
    2. Test Data Creation.
    
    Update History
    --------------
    Created Dec 2014 - A.B.
    TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
     
    
    Issues / TODOs
    --------------
   
*/
@isTest
private class SMBW2_UserAssignment_GlobalTeaming_Test {
    
    //A.T.T.R.I.B.U.T.E.S
    static Map<String,Id> RTIdtoRTDevNameMap = new Map<String,Id>();
    //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
    //static String acct15=''; /*15-digit account number*/
    static ID acct18 = null; /*18-digit account number*/
    static String terrDeveloperNameforParent =''; /*Holds territory developer name for parent account*/
    static String terrDeveloperNameforChild =''; /*Holds territory developer name for child account*/
    static Account gamacc = new Account(); /*For creating GAM Account*/
    static Account nongamacc = new Account(); /*For creating Non-GAM account*/
    static User usr1 = new User(); /*For creating users*/
    static User usr2 = new User();
    //A.T.T.R.I.B.U.T.E.S
    
    
    //1. Test Method to 
    static testMethod void updateContact(){
    
    
        //To get Id for System Admin profile
        Profile pro = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        //Creating user with System Administrator profile
        User usr = new User(Alias = 'sysadm', Email='test999@orange.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = pro.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='sysadminuser@testorg.com.test',SMB_Sales_Region__c = 'N/A');
        //Running user as System Admin
        System.runAs (usr) {
        //Test Data creation for Account and users.
        createTestData();
       
        Test.startTest();
        
        //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
        //To get 15-digit account number
        //acct15 = String.ValueOf(gamacc.Id).substring(0, 15);
        acct18 = gamacc.Id;
        //PageReference Apex class to instantiate a page
        PageReference pageRef = Page.SMBW2_ACC_TerritoryManage_VFP;
        Test.setCurrentPage(pageRef);
        //Add parameters to page
        //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
        //Apexpages.currentPage().getParameters().put('accid', acct15);
        Apexpages.currentPage().getParameters().put('accid', acct18);
        Apexpages.currentPage().getParameters().put('create', 'true');
        //Instantiate a new controller with all parameters in the page 
        ApexPages.StandardController scTest = new ApexPages.standardController(gamacc);
        SMBW2_ACC_TerritoryManage_VFC aTest = new SMBW2_ACC_TerritoryManage_VFC(scTest);
        //Calling init() method from class SMBW2_ACC_TerritoryManage_VFC for creation of a territory hierarchy with 2 territories, rule that associate accounts to the territories, and association of users
        aTest.init();
        //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
        //Getting Developer name for parent territory
        //terrDeveloperNameforParent = 'Territory_'+acct15;
        terrDeveloperNameforParent = 'Territory_'+acct18;
        //List holds territory data with associated Developer Name for parent account
        List<Territory2> t = [Select t.Id,t.Name, t.DeveloperName From Territory2 t Where t.DeveloperName Like: terrDeveloperNameforParent];
        Test.stopTest();
        //terrDeveloperName1 = 'Territory_'+acct;  
        //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
        //Getting Developer name for child territory
        //terrDeveloperNameforChild = 'Territory_'+acct15+'_Read';
        terrDeveloperNameforChild = 'Territory_'+acct18+'_Read';
        //List holds territory data with associated Developer Name for child account 
        List<Territory2> t2 = [Select t.Id,t.Name, t.DeveloperName From Territory2 t Where t.DeveloperName Like: terrDeveloperNameforChild];
        //List<Territory2> t1 = [Select t.Id,t.Name, t.DeveloperName From Territory2 t Where t.DeveloperName Like: terrDeveloperName1];
        //To check if territory is created
        
        System.assertEquals(true, [SELECT Id, SMB_ACC_Territory_Created__c FROM Account WHERE Id =: gamacc.Id limit 1].SMB_ACC_Territory_Created__c);
        //change owner for GAM account
        gamacc.OwnerId = usr1.Id;
        update gamacc;
        //assigning team members to the account
        AccountTeamMember accTM = new AccountTeamMember(UserId = usr2.Id,TeamMemberRole = 'Pre-Sales',AccountId = gamacc.Id);
        insert accTM;     
        //Calling SMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories() for user assignment to the territories.
        SMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories();
        //TKT-3114
//        SMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories1();
//        SMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories2();
        //To check if the user assigned to the territory
        System.assertEquals(gamacc.OwnerId, [Select u.Territory2Id,u.UserId, u.Id From UserTerritory2Association u Where u.Territory2Id =:t[0].Id limit 1].UserId);     
        //To check the size of child territory
        list<AggregateResult> result = [Select count(t.UserId)c From UserTerritory2Association t Where t.Territory2Id =: t2[0].Id];
        Integer count = (Integer) result[0].get('c');
        System.assertEquals(3,count);
    
    }
    
}       


    static testMethod void updateContact1(){
    
    
        //To get Id for System Admin profile
        Profile pro = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        //Creating user with System Administrator profile
        User usr = new User(Alias = 'sysadm', Email='test999@orange.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = pro.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='sysadminuser@testorg.com.test',SMB_Sales_Region__c = 'N/A');
        //Running user as System Admin
        System.runAs (usr) {
        //Test Data creation for Account and users.
        createTestData();
       
        Test.startTest();
        
        //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
        //To get 15-digit account number
        //acct15 = String.ValueOf(gamacc.Id).substring(0, 15);
        acct18 = gamacc.Id;
        //PageReference Apex class to instantiate a page
        PageReference pageRef = Page.SMBW2_ACC_TerritoryManage_VFP;
        Test.setCurrentPage(pageRef);
        //Add parameters to page
        //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
        //Apexpages.currentPage().getParameters().put('accid', acct15);
        Apexpages.currentPage().getParameters().put('accid', acct18);
        Apexpages.currentPage().getParameters().put('create', 'true');
        //Instantiate a new controller with all parameters in the page 
        ApexPages.StandardController scTest = new ApexPages.standardController(gamacc);
        SMBW2_ACC_TerritoryManage_VFC aTest = new SMBW2_ACC_TerritoryManage_VFC(scTest);
        //Calling init() method from class SMBW2_ACC_TerritoryManage_VFC for creation of a territory hierarchy with 2 territories, rule that associate accounts to the territories, and association of users
        aTest.init();
        //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
        //Getting Developer name for parent territory
        //terrDeveloperNameforParent = 'Territory_'+acct15;
        terrDeveloperNameforParent = 'Territory_'+acct18;
        //List holds territory data with associated Developer Name for parent account
        List<Territory2> t = [Select t.Id,t.Name, t.DeveloperName From Territory2 t Where t.DeveloperName Like: terrDeveloperNameforParent];
        Test.stopTest();
        //terrDeveloperName1 = 'Territory_'+acct;  
        //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
        //Getting Developer name for child territory
        //terrDeveloperNameforChild = 'Territory_'+acct15+'_Read';
        terrDeveloperNameforChild = 'Territory_'+acct18+'_Read';
        //List holds territory data with associated Developer Name for child account 
        List<Territory2> t2 = [Select t.Id,t.Name, t.DeveloperName From Territory2 t Where t.DeveloperName Like: terrDeveloperNameforChild];
        //List<Territory2> t1 = [Select t.Id,t.Name, t.DeveloperName From Territory2 t Where t.DeveloperName Like: terrDeveloperName1];
        //To check if territory is created
        
        //System.assertEquals(true, [SELECT Id, SMB_ACC_Territory_Created__c FROM Account WHERE Id =: gamacc.Id limit 1].SMB_ACC_Territory_Created__c);
        //change owner for GAM account
        gamacc.OwnerId = usr1.Id;
        update gamacc;
        //assigning team members to the account
        AccountTeamMember accTM = new AccountTeamMember(UserId = usr2.Id,TeamMemberRole = 'Pre-Sales',AccountId = gamacc.Id);
        insert accTM;     
        //Calling SMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories() for user assignment to the territories.
        //SMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories();
        //TKT-3114
        SMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories1();
//        SMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories2();
        //To check if the user assigned to the territory
        //System.assertEquals(gamacc.OwnerId, [Select u.Territory2Id,u.UserId, u.Id From UserTerritory2Association u Where u.Territory2Id =:t[0].Id limit 1].UserId);     
        //To check the size of child territory
        list<AggregateResult> result = [Select count(t.UserId)c From UserTerritory2Association t Where t.Territory2Id =: t2[0].Id];
        Integer count = (Integer) result[0].get('c');
        //System.assertEquals(3,count);
    
    }
    
}       


    static testMethod void updateContact2(){
    
    
        //To get Id for System Admin profile
        Profile pro = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        //Creating user with System Administrator profile
        User usr = new User(Alias = 'sysadm', Email='test999@orange.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = pro.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='sysadminuser@testorg.com.test',SMB_Sales_Region__c = 'N/A');
        //Running user as System Admin
        System.runAs (usr) {
        //Test Data creation for Account and users.
        createTestData();
       
        Test.startTest();
        
        //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
        //To get 15-digit account number
        //acct15 = String.ValueOf(gamacc.Id).substring(0, 15);
        acct18 = gamacc.Id;
        //PageReference Apex class to instantiate a page
        PageReference pageRef = Page.SMBW2_ACC_TerritoryManage_VFP;
        Test.setCurrentPage(pageRef);
        //Add parameters to page
        //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
        //Apexpages.currentPage().getParameters().put('accid', acct15);
        Apexpages.currentPage().getParameters().put('accid', acct18);
        Apexpages.currentPage().getParameters().put('create', 'true');
        //Instantiate a new controller with all parameters in the page 
        ApexPages.StandardController scTest = new ApexPages.standardController(gamacc);
        SMBW2_ACC_TerritoryManage_VFC aTest = new SMBW2_ACC_TerritoryManage_VFC(scTest);
        //Calling init() method from class SMBW2_ACC_TerritoryManage_VFC for creation of a territory hierarchy with 2 territories, rule that associate accounts to the territories, and association of users
        aTest.init();
        //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
        //Getting Developer name for parent territory
        //terrDeveloperNameforParent = 'Territory_'+acct15;
        terrDeveloperNameforParent = 'Territory_'+acct18;
        //List holds territory data with associated Developer Name for parent account
        List<Territory2> t = [Select t.Id,t.Name, t.DeveloperName From Territory2 t Where t.DeveloperName Like: terrDeveloperNameforParent];
        Test.stopTest();
        //terrDeveloperName1 = 'Territory_'+acct;  
        //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
        //Getting Developer name for child territory
        //terrDeveloperNameforChild = 'Territory_'+acct15+'_Read';
        terrDeveloperNameforChild = 'Territory_'+acct18+'_Read';
        //List holds territory data with associated Developer Name for child account 
        List<Territory2> t2 = [Select t.Id,t.Name, t.DeveloperName From Territory2 t Where t.DeveloperName Like: terrDeveloperNameforChild];
        //List<Territory2> t1 = [Select t.Id,t.Name, t.DeveloperName From Territory2 t Where t.DeveloperName Like: terrDeveloperName1];
        //To check if territory is created
        
        //System.assertEquals(true, [SELECT Id, SMB_ACC_Territory_Created__c FROM Account WHERE Id =: gamacc.Id limit 1].SMB_ACC_Territory_Created__c);
        //change owner for GAM account
        gamacc.OwnerId = usr1.Id;
        update gamacc;
        //assigning team members to the account
        AccountTeamMember accTM = new AccountTeamMember(UserId = usr2.Id,TeamMemberRole = 'Pre-Sales',AccountId = gamacc.Id);
        insert accTM;     
        //Calling SMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories() for user assignment to the territories.
        //SMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories();
        //TKT-3114
//        SMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories1();
        SMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories2();
        //To check if the user assigned to the territory
        //System.assertEquals(gamacc.OwnerId, [Select u.Territory2Id,u.UserId, u.Id From UserTerritory2Association u Where u.Territory2Id =:t[0].Id limit 1].UserId);     
        //To check the size of child territory
        list<AggregateResult> result = [Select count(t.UserId)c From UserTerritory2Association t Where t.Territory2Id =: t2[0].Id];
        Integer count = (Integer) result[0].get('c');
        //System.assertEquals(3,count);
    
    }
    
}       

    //2. Test Data creation for Account and users.
    public static void createTestData(){    
        
        //Creating RecordType Id To Record Type Developer Name Map. 
        for(RecordType recordtype:  [Select r.SobjectType, r.DeveloperName, r.Id From RecordType r where r.SobjectType ='Account']){
            RTIdtoRTDevNameMap.put(recordtype.DeveloperName,recordtype.Id);
        }
        List<RecordType> listRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
        AND IsActive = true order by DeveloperName];
        //creating a GAM account  
        gamacc.Name='ATestAccount';
        //gamacc.Sales_Region__c = 'N/A';
        gamacc.SMB_No_Referential_ID_available__c =true;
        gamacc.RecordTypeId =  RTIdtoRTDevNameMap.get('Prospect');
        insert gamacc;
        
        //creating a Non-GAM account
         nongamacc.Name='TestAccountNonGAM';                  
         nongamacc.ParentId = gamacc.Id;
         //nongamacc.Sales_Region__c = 'N/A';
         nongamacc.SMB_No_Referential_ID_available__c =true;
         nongamacc.RecordTypeId =  RTIdtoRTDevNameMap.get('Prospect');     
         insert nongamacc;

        //creating a user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        usr1.alias = 'alTest';
        usr1.email = 'test999@orange.com';
        usr1.profileid = p.Id;   
        usr1.localesidkey ='en_US';
        usr1.timezonesidkey ='America/Los_Angeles';
        usr1.username ='test@devTest.com.test';
        usr1.CommunityNickname = 'test@devTest.com.test';
        usr1.languagelocalekey ='en_US';
        usr1.FirstName ='FN';
        usr1.LastName ='LN';
        usr1.emailencodingkey ='UTF-8';
        insert usr1;
        
        //creating user2
        usr2.alias = 'alTest2';
        usr2.email = 'test9994@orange.com';
        usr2.profileid = p.Id; 
        usr2.localesidkey ='en_US';
        usr2.timezonesidkey ='America/Los_Angeles';
        usr2.username ='test@devTest.com.test2';
        usr2.CommunityNickname = 'test@devTest.com.test2';
        usr2.languagelocalekey ='en_US';
        usr2.FirstName ='FN2';
        usr2.LastName ='LN2';
        usr2.emailencodingkey ='UTF-8';
        insert usr2;
        
        //assigning team members to the account
        AccountTeamMember acM0 = new AccountTeamMember(UserId = usr1.Id,TeamMemberRole = 'Pre-Sales',AccountId = gamacc.Id);
        insert acM0;
        //assigning team members to the non GAM account
        AccountTeamMember acM1 = new AccountTeamMember(UserId = usr2.Id,TeamMemberRole = 'Pre-Sales',AccountId = nongamacc.Id);
        insert acM1;
        
        
    }
                
}