public class TestDataCreation{

//Added by Kd on 19th Oct 2015:
    public static List<Release__c> createReleases(Integer numRel, String status){
        List<Release__c> relList = new List<Release__c>();
        if (status==null || status.equals('')) {
            status='Draft';
        }
        for(Integer i=0; i<numRel; i++){
            relList.add(new Release__c(Name='Test'+i, Wave__c=i, Status__c=status));
        }
        return insertRecord(relList);
    }
    
    public static List<User_Story__c> createUserStories(Integer numUS, User usr){
        List<User_Story__c> usList = new List<User_Story__c>();
        for(Integer i=0; i<numUS; i++){
            usList.add(new User_Story__c(User_Story_Title__c='test'+i,Domain__c='Product Management',
            Requirement_Description__c='test test test test test test test test test test',
            International_Business_through_Teaming__c='1. Low', Sales_Marketing_Efficiency__c='1. Low', Simpler_Accurate_Reporting__c='1. Low'));
        }
        return insertRecord(usList);
    }

    public static List<UAT__c> createUATs(Integer numUATs, Release__c rel){
        if (rel==null){
            rel=createReleases(1, null)[0];
        }
        List<UAT__c> uatsList = new List<UAT__c>();
        for(Integer i=0; i<numUATs; i++){
            uatsList.add(new UAT__c(Name='test'+i, Release__c=rel.id));
        }
        return insertRecord(uatsList);
    }

    public static List<UAT_Scenario__c> createUATScenarios(Integer numUATScs, UAT__c uat){
        if (uat==null){
            uat=createUATs(1, null)[0];
        }
        List<UAT_Scenario__c> uatScsList = new List<UAT_Scenario__c>();
        for(Integer i=0; i<numUATScs; i++){
            uatScsList.add(new UAT_Scenario__c(Name='test'+i, Parent_UAT__c=uat.id));
        }
        return insertRecord(uatScsList);
    }

    public static List<Defects__c> createDefects(Integer numDef, Release__c rel){
        List<Defects__c> defList = new List<Defects__c>();
        for(Integer i=0; i<numDef; i++){
            defList.add(new Defects__c(Domain__c='Product Management', Type__c='Defect',Release__c=rel.id,
            Severity__c='Low', Title__c='test'+i, Issue_and_Description__c='test test test test test test test test test test',
            Expected_Result__c='test test', Detection_Date__c=System.today(), Status__c='1. New'));
        }
        return insertRecord(defList);
    }
    
    public static List<Account> createEntitySubscription(Integer numES, Id parentId, Id subId){
        List<EntitySubscription> esList = new List<EntitySubscription>();
        for(Integer i=0; i<numES; i++){
            esList.add(new EntitySubscription(ParentId=parentId, SubscriberId=subId));
        }
        return insertRecord(esList);
    }

    //public static Long vatInt=1000000000;
    public static List<Account> createAccounts(Integer numAcc){
        List<Account> accList = new List<Account>();
        for(Integer i=0; i<numAcc; i++){
            accList.add(new Account(Name='Test'+i,RCE_ID__c='hjht4567'));
            //accList.add(new Account(Name='Test'+i,RCE_ID__c='hjht4567', iSell__OSKeyID__c='testtest', VAT_Number__c=String.valueOf(vatInt++)));
        }
        return insertRecord(accList);
    }
    
    public static List<Account> createultimateAccounts(Integer numAcc,id accid){
        List<Account> accList = new List<Account>();
        for(Integer i=0; i<numAcc; i++){
            accList.add(new Account(Name='Test'+i,Ultimate_Parent_Account__c=accid));
        }
        return insertRecord(accList);
    }
    
    public static List<SMB_Setting_Region__c> createSettingRegion(Integer numSettReg, String name){
        List<SMB_Setting_Region__c> settingRegionList = new List<SMB_Setting_Region__c>();
        for(Integer i=0; i<numSettReg; i++){
            settingRegionList.add(new SMB_Setting_Region__c(Name=name, Channel__c='Test', Domain__c='Test'));
        }
        return insertRecord(settingRegionList);
    }
    
    public static List<Product2> createProduct(Integer numProduct, String name){
        List<Product2> productList = new List<Product2>();
        for(Integer i=0; i<numProduct; i++){
            productList.add(new Product2(Name=name, Channel__c='Test', Domains__c='Test', isActive=true, currencyIsoCode='USD'));
        }
        return insertRecord(productList);
    }
    
    public static List<PriceBookEntry> createPriceBookEntry(Integer numPriceBookEntry, Id prodId, Id priceBookId){
        List<PriceBookEntry> priceBookList = new List<PriceBookEntry>();
        for(Integer i=0; i<numPriceBookEntry; i++){
            priceBookList.add(new PriceBookEntry(Product2Id=prodId, Pricebook2Id= priceBookId, UnitPrice=1, IsActive=true));
        }
        return insertRecord(priceBookList);
    }
    
    public static List<OpportunityLineItem> createOpportunityLineItem(Integer numOpp, Id oppId, Integer quantity, Id pricebookEntryId){
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        for(Integer i=0; i<numOpp; i++){
            oppLineItemList.add(new OpportunityLineItem(OpportunityId=OppId, Quantity=quantity, TotalPrice=1, PricebookEntryId=pricebookEntryId));
        }
        return insertRecord(oppLineItemList);
    }

    public static List<Opportunity> createOpportunities(Integer numOpp){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0; i<numOpp; i++){
            oppList.add(new Opportunity(CloseDate=Date.today().addDays(1), Name='Test'+i, StageName='3 Proposal', 
                                        GAM_type__c='Standard GAM', Standard_GAM_Registered__c=true, Amount=10,
                                        CurrentDateTime_OnChange_Of_Registration__c = Datetime.now().addMinutes(-15),
                                        Smb_opportunity_without_partner__c=true));
        }
        return insertRecord(oppList);
    }
    
    public static List<Opportunity> createOpportunitiesWithPriceBook(Integer numOpp, Id pbId){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0; i<numOpp; i++){
            oppList.add(new Opportunity(CloseDate=Date.today().addDays(1), Name='Test'+i, StageName='1 Pre-qualification', 
                                        GAM_type__c='Standard GAM', Standard_GAM_Registered__c=true,SMB_OPP_Must_Win_level__c='',
                                        CurrentDateTime_OnChange_Of_Registration__c = Datetime.now().addMinutes(-15), pricebook2id=pbId, 
                                        currencyIsoCode='USD'));
        }
        return insertRecord(oppList);
    }
    
    public static List<Opportunity> createOpportunitiesWithAccount(Integer numOpp, Id accId){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0; i<numOpp; i++){
            oppList.add(new Opportunity(CloseDate=Date.today().addDays(1), Name='Test'+i, StageName='1 Pre-qualification', Amount=10,
                                        GAM_type__c='Standard GAM', Standard_GAM_Registered__c=true, AccountId = accId,SMB_OPP_Must_Win_level__c='',
                                        CurrentDateTime_OnChange_Of_Registration__c = Datetime.now().addMinutes(-15),
                                        Smb_opportunity_without_partner__c=true));
        }
        return insertRecord(oppList);
    }
    
    public static List<Opportunity> createOpportunitiesWithAccountProposal(Integer numOpp, Id accId){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0; i<numOpp; i++){
            oppList.add(new Opportunity(CloseDate=Date.today().addDays(1), Name='Test'+i, StageName='3 Proposal', 
                                        GAM_type__c='Standard GAM', Standard_GAM_Registered__c=true, AccountId = accId,SMB_OPP_Must_Win_level__c='',
                                        CurrentDateTime_OnChange_Of_Registration__c = Datetime.now().addMinutes(-15),
                                        Smb_opportunity_without_partner__c=true));
        }
        return insertRecord(oppList);
    }
    
        public static List<Contact> createContactsWithAccount(Integer numOpp, Id accId, String usernamePrefix){
        List<Contact> conList = new List<Contact>();
        for(Integer i=0; i<numOpp; i++){
            conList.add(new Contact(email=usernamePrefix+i+'@testorg.com', firstname='Test'+i, LastName='Test'+i,  AccountId = accId));
        }
        return insertRecord(conList);
    }

    
    public static List<OpportunityTeamMember> createOpportunityTeamMember(Integer numOppMem, Id oppId, Id userId){
        List<OpportunityTeamMember> oppTeamMemberList = new List<OpportunityTeamMember>();
        for(Integer i=0; i<numOppMem; i++){
            oppTeamMemberList.add(new OpportunityTeamMember(UserId=userId, OpportunityId=oppId,TeamMemberRole='OME BID MANAGER'));
        }
        return insertRecord(oppTeamMemberList);
    }
    
    public static List<User> createUsers(Integer numUser, String profileName, String freq, Id userRoleId){
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName];
        for(Integer i=0; i<numUser; i++){
            userList.add(new User
            (Alias = 'standt'+i, Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing'+i, 
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
            UserName=profileName.deleteWhitespace()+'user'+i+'@testorg.com', SMB_User_Notify__c=true, Frequency__c=freq,SMB_Bypass_VR__c=true,SMB_Bypass_WF__c=true,PAD_BypassTrigger__c='', 
            UserRoleId=userRoleId));
        }
        return insertRecord(userList);
    }
    
    
    public static List<User> createUsersWithUsernamePrefixAlias(Integer numUser, String profileName, String freq, Id userRoleId, String usernamePrefix, String aliasName){
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName];
        for(Integer i=0; i<numUser; i++){
            userList.add(new User
            (Alias = aliasName+i, Email=usernamePrefix+'@testorg.com', EmailEncodingKey='UTF-8', LastName=usernamePrefix+i, 
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
            UserName=profileName.deleteWhitespace()+'user'+i+'@Orangetestorg.com', SMB_User_Notify__c=true, Frequency__c=freq,SMB_Bypass_VR__c=true,SMB_Bypass_WF__c=true,PAD_BypassTrigger__c='', 
            UserRoleId=userRoleId));
        }
        return insertRecord(userList);
    }
    
    public static List<UserRole> createUserRoles(Integer numUserRoles, Id parentRoleId){
        List<UserRole> userRoleList = new List<UserRole>();
        for(Integer i=0; i<numUserRoles; i++){
            userRoleList.add(new UserRole(Name='userRole'+i, ParentRoleId=parentRoleId));
        }
        return insertRecord(userRoleList);
    }
    
    public static List<Note> createNotes(Integer numNotes, Id parentId){
        List<Note> noteList = new List<Note>();
        for(Integer i=0; i<numNotes; i++){
            noteList.add(new Note(Title='Test'+i, ParentId=parentId));
        }
        return insertRecord(noteList);
    }
    
    public static List<Attachment> createAttachments(Integer numAttach, Id parentId){
        List<Attachment> attachList = new List<Attachment>();
        for(Integer i=0; i<numAttach; i++){
            attachList.add(new Attachment(Name='Test'+i, Body=Blob.valueOf('body'),ParentId=parentId));
        }
        return insertRecord(attachList);
    }
    
    public static List<Master_Attachment_Approval__c> createMasterAttachApprovals(Integer numAttachApproval, Id attachId, 
                                                                                    Boolean approvFlag){
        List<Master_Attachment_Approval__c> attachApprovalList = new List<Master_Attachment_Approval__c>();
        for(Integer i=0; i<numAttachApproval; i++){
            attachApprovalList.add(new Master_Attachment_Approval__c(Attachment_id__c=attachId, Approve__c=approvFlag));
        }
        return insertRecord(attachApprovalList);
    }
    
    public static List<Task> createTasks(Integer numTask, Id oppId){
        List<Task> taskList= new List<Task>();
        for(Integer i=0; i<numTask; i++){
            taskList.add(new Task(Status='Completed', Priority='Low', WhatId=oppId, Category__c='Proposal'));
        }
        return insertRecord(taskList);
    }
    
   
    
    public static List<OpportunitySplit> createOppSplit(Integer numOppSplit, Id oppId){
        List<OpportunitySplit> oppSplitList= new List<OpportunitySplit>();
        for(Integer i=0; i<numOppSplit; i++){
            oppSplitList.add(new OpportunitySplit(OpportunityId=oppId, SplitOwnerId=UserInfo.getUserId()));
        }
        return insertRecord(oppSplitList);
    }
    
    public static List<Split__c> createSplit(Integer numSplit, String name, Id splitId){
        List<Split__c> splitList= new List<Split__c>();
        for(Integer i=0; i<numSplit; i++){
            splitList.add(new Split__c(Name=name, Split_id__c=splitId));
        }
        return insertRecord(splitList);
    }
    
     public static List<Split__c> createSplitsales(Integer numSplit, String pname ){
        List<Split__c> splitList= new List<Split__c>();
        profile p=[select name,id from profile where name=:pname];
        for(Integer i=0; i<numSplit; i++){
            splitList.add(new Split__c(Name=pname, Split_id__c=p.id));
        }
        return insertRecord(splitList);
    }
    
    public static List<Split__c> createSplitfinance(Integer numSplit, String name){
        List<Split__c> splitList= new List<Split__c>();
        OpportunitySplitType opsplittype=[SELECT Id,MasterLabel,DeveloperName  FROM OpportunitySplitType WHERE DeveloperName = 'Revenue'][0];
        for(Integer i=0; i<numSplit; i++){
            splitList.add(new Split__c(Name=name, Split_id__c=opsplittype.id));
        }
        return insertRecord(splitList);
    }
    
    public static List<Split__c> createSplitcommission(Integer numSplit, String name){
        List<Split__c> splitList= new List<Split__c>();
        OpportunitySplitType opsplittype=[SELECT Id,MasterLabel,DeveloperName  FROM OpportunitySplitType WHERE DeveloperName= 'Overlay'][0];
        for(Integer i=0; i<numSplit; i++){
            splitList.add(new Split__c(Name=name, Split_id__c=opsplittype.id));
        }
        return insertRecord(splitList);
    }
    
     public static List<OpportunitySplit> createOppSplitcommission(Integer numOppSplit, Id oppId){
        List<OpportunitySplit> oppSplitList= new List<OpportunitySplit>();
        OpportunitySplitType opsplittype=[SELECT Id,MasterLabel,DeveloperName  FROM OpportunitySplitType WHERE DeveloperName= 'Overlay'][0];
        list<user> us=[SELECT Id,profile.name FROM User where profile.name='sales user samba' and IsActive=true and id!=:UserInfo.getUserId()];
/* To avoid duplicate entry will start for loop from 2nd user
        for(Integer i=0; i<numOppSplit; i++){
            oppSplitList.add(new OpportunitySplit(OpportunityId=oppId,SplitTypeId=opsplittype.id,SplitPercentage=100,CommissionPercent__c=100,SplitOwnerId=us[i].id));
        }
*/
        for(Integer i=1; i<numOppSplit+1; i++){
            oppSplitList.add(new OpportunitySplit(OpportunityId=oppId,SplitTypeId=opsplittype.id,SplitPercentage=100,CommissionPercent__c=100,SplitOwnerId=us[i].id));
        }

        return insertRecord(oppSplitList);
    }
    
       public static List<OpportunitySplit> createOppSplitfinance(Integer numOppSplit, Id oppId){
        List<OpportunitySplit> oppSplitList= new List<OpportunitySplit>();
        OpportunitySplitType opsplittype=[SELECT Id,MasterLabel,DeveloperName  FROM OpportunitySplitType WHERE DeveloperName = 'Revenue'][0];
        list<user> us=[SELECT Id,profile.name FROM User where profile.name='sales user samba' and IsActive=true and id!=:UserInfo.getUserId()];
        for(Integer i=5; i<numOppSplit+5; i++){
            oppSplitList.add(new OpportunitySplit(OpportunityId=oppId,SplitTypeId=opsplittype.id,SplitPercentage=10,Finance_Percent__c=10,SplitOwnerId=us[i+3].id));
        }
        
        return insertRecord(oppSplitList);
    }
    
     public static List<Profiles__c> Createcustomsetting_profile(){
     List<Profiles__c> Profilelist= new List<Profiles__c>();
     list<String> Profile_name= new List<String>{
             'Regional Administrator User SAMBA', 'Sales Operation User SAMBA', 'System Administrator'
     };
        System.debug('jjjjjjj'+Profile_name);
        List<Profile> profiledata= [Select Id ,Name from Profile where Name In :Profile_name];
        System.debug('kkkkkkkkk'+Profiledata);
        for(Profile p:Profiledata){
            String Profilename=P.Name.replaceAll(' ','_');
             System.debug('Profilename'+Profilename);
            Profiles__c Pc=new Profiles__c(Name=Profilename,Id__c=P.id);
            Profilelist.add(Pc);
        }
        System.debug('Profilelist'+Profilelist);
        return insertRecord(Profilelist);
    }
    
    public static List<Lead_Marketing_Manager_Mapping__c> CreateMarketingManager(user userlist){
        List<Lead_Marketing_Manager_Mapping__c> MarketingManagerList = new List<Lead_Marketing_Manager_Mapping__c>();
        list<user> us=[SELECT Id,profile.name,Name FROM User where profile.name='Regional Administrator User SAMBA' and IsActive=true];
      //  list<User> userNAM = [SELECT Id,profile.name,Name FROM User where profile.name='Regional Administrator User SAMBA' and IsActive=true and SMB_Sales_Cluster__c='OCB' limit 1];
            MarketingManagerList.add(new Lead_Marketing_Manager_Mapping__c(Name='NAM', Marketing_Manager_Id__c=us[0].Id)); 
            MarketingManagerList.add(new Lead_Marketing_Manager_Mapping__c(Name='Default', Marketing_Manager_Id__c=us[1].Id));
            MarketingManagerList.add(new Lead_Marketing_Manager_Mapping__c(Name='APAC Region', Marketing_Manager_Id__c=us[2].Id));
           if(userlist!=null){
            MarketingManagerList.add(new Lead_Marketing_Manager_Mapping__c(Name='OCB', Marketing_Manager_Id__c=userlist.id));
            }
        return insertRecord(MarketingManagerList);
    }
     public static List<Lead> CreateLead(){
        List<Lead> ListLead = new List<Lead>();
            ListLead.add(new Lead(LastName='Testlead',firstname='test', Status='Open',Email='test@gmail.com',Company='Company',Headquarters_country__c='Italy',LeadSource='Contact Us Form')); 
            ListLead.add(new Lead(LastName='Testlead1',firstname='test', Status='Open',Email='test1@gmail.com',Company='Company',Headquarters_country__c='Italy',LeadSource='Contact Us Form'));
       
        return insertRecord(ListLead);
    }
    
    public static List<Action_Plan__c> CreateActionPlan(Integer no, Id Accids){
        List<Action_Plan__c> createInsert = new List<Action_Plan__c>();
        
         for(integer i = 0; i<no; i++){
         Action_Plan__c ap = new Action_Plan__c (Name='testAction'+'i', 
                      SMB_AP_Account__c=Accids,SMB_AP_IsActive__c=true); 
         createInsert.add(ap);
      }
            
        return insertRecord(createInsert);
    }
    
    public static List<AccountTeamMember> CreateAccountTeamMember(Id Accids,list<user>Userid){
        List<AccountTeamMember> createActionPlan = new List<AccountTeamMember>();
         for(integer i = 0; i<Userid.size(); i++){
         AccountTeamMember atm = new AccountTeamMember(AccountId=Accids,TeamMemberRole='Marketing',
                                 UserId=Userid[i].id); 
         createActionPlan.add(atm );
      }
            
       return insertRecord(createActionPlan);
    }
    public static QueueSobject CreateQueue(){
        Group grp = new Group(Name='APAC',Type='Queue');
        insert grp;
        QueueSobject mappingObject = new QueueSobject(QueueId =grp.Id, SobjectType = 'Lead');
        insert mappingObject;
        return mappingObject;
      }
    
    public static List<Lead> CreateLeadwithqueueOwner(){
        List<Lead> ListLead = new List<Lead>();
            ListLead.add(new Lead(LastName='Testlead',LeadSource='Contact Us Form',Headquarters_country__c='Canada',Status='Open',Email='test@gmail.com',Company='Company')); 
            ListLead.add(new Lead(LastName='Testlead1',LeadSource='Contact Us Form',Headquarters_country__c='India', Status='Open',Email='test1@gmail.com',Company='Company'));
       
        return insertRecord(ListLead);
    }
    public static List<Campaign> CreateCampaign(){
        List<Campaign> ListCampaign = new List<Campaign>();
            ListCampaign.add(new Campaign(Name='Testcampaign',Type='Email',Description='test')); 
            ListCampaign.add(new Campaign(Name='Testcampaign1',Type='Advertisement',Description='test'));
            
       
        return insertRecord(ListCampaign);
    }
    public static List<CampaignStatus__c > CreateCampaignStatus(){
        List<CampaignStatus__c > ListCampaignStatus = new List<CampaignStatus__c >();
            ListCampaignStatus.add(new CampaignStatus__c(Campaign_Status__c='Email',Camp_Type__c='Email', HasResponded__c=false, IsDefault__c =false,name ='email', SortOrder__c ='1'));
            ListCampaignStatus.add(new CampaignStatus__c(Campaign_Status__c='Other',Camp_Type__c='Other',HasResponded__c=false, IsDefault__c =false,name ='Other', SortOrder__c ='2'));
        return insertRecord(ListCampaignStatus );
    }  
    
    public static List<Partner> CreatePartner(id Accid,id oppid){
        List<Partner> ListPartner  = new List<Partner>();
            ListPartner.add(new Partner(accountToId = Accid, opportunityId = oppid, role='Channel', isPrimary = true));
            ListPartner.add(new Partner(accountToId = Accid, opportunityId = oppid, role='Leader', isPrimary = false));
        return insertRecord(ListPartner);
    }        
    
    public static List<sObject> insertRecord(List<sObject> objectList){
        insert objectList;
        return objectList;
    }
    
}