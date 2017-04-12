/*******************************************************
Created by J. Hazebrouck
TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
TKT-2172 OLM 15/3/30 use SMB_ACC_Ultimate_Parent_18_Id_F__c  for rule instead of SMB_Ultimate_Parent_Id__c 


Management of the territory hierarchy:
Creation of a territory hierarchy with 2 territories, a rule that associate accounts to the territories, and
association of users
OR
Deletion of the territories and associated rule

Note, the functionality is used like this:
1) Click create global teaming button on a top account
2) Each night
	a)SetupàManageTerritoriesàTerritory Model àView Hierarchy à RUN ALL RULES
	b)Developer Console à DebugàOpen Execute Anonymous Window àSMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories();

What happens:
	-CreateTerritory Class creates the territory and rule
	-Run assign rules maintains list of accounts on the territory (since we don’t use run rule on saving account since account are batch loaded)
	-SMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories(); maintains list of user on territory



*******************************************************/
public without sharing class SMBW2_ACC_TerritoryManage_VFC {
    
	//TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
    //public String  accId;
    public Id accId;
    public String boolCreate;
    public integer iDedupSuffix = 0;
    
    public SMBW2_ACC_TerritoryManage_VFC(ApexPages.StandardController controller){
        accId = Apexpages.currentPage().getParameters().get('AccId');
        boolCreate = Apexpages.currentPage().getParameters().get('create');
    }
    
    public pageReference init(){
        try{
            //boolCreate = true ==> Creation of the territory management
            if(boolCreate == 'true'){
                //We retrieve the territory model and territory type that will contain all territory
                Territory2Model terModel = [SELECT Id, DeveloperName FROM Territory2Model WHERE DeveloperName =: System.Label.SMB_CL023_Territory_Model limit 1];
                Territory2Type terType = [SELECT Id, DeveloperName FROM Territory2Type WHERE DeveloperName =: System.Label.SMB_CL024_Territory_Type limit 1];
                
                //We need to create 2 territories: terGAM with Read/Write access for top level account owner
                Territory2 terGAM = new Territory2(accountAccessLevel = 'Edit', caseAccessLevel = 'Edit',
                opportunityAccessLevel = 'Edit',ContactAccessLevel ='Edit', Name = accId, territory2TypeId = terType.Id,
                territory2ModelId = terModel.Id, DeveloperName = 'Territory_' + accId);
                insert terGAM;
                
                /*Territory2 ter = new Territory2(accountAccessLevel = 'Read', caseAccessLevel = 'Read',
                opportunityAccessLevel = 'Read', Name = accId + ' Read', territory2TypeId = terType.Id,
                territory2ModelId = terModel.Id, DeveloperName = 'Territory_' + accId + '_Read',
                parentTerritory2Id = terGAM.Id);
                insert ter;*/
                
                //Child Territory will have the Object access level based on the "Territory Management" Default Access Level Settings.
                Territory2 ter = new Territory2(Name = accId + ' Read', territory2TypeId = terType.Id,
                territory2ModelId = terModel.Id, DeveloperName = 'Territory_' + accId + '_Read',
                parentTerritory2Id = terGAM.Id);
                insert ter;
                
                //We setup the rule that will run to retrieve accounts and attach them to the territories
                ObjectTerritory2AssignmentRule assignRule = new ObjectTerritory2AssignmentRule(DeveloperName = 'Rule_' + accId,
                isActive = true, MasterLabel = 'Rule ' + accId, Territory2ModelId = terModel.Id, ObjectType = 'Account');
                insert assignRule;
                
                //The rule item defines the criteria to retrieve the accounts
                //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
                // Sadly it is not possible at this stage to have SMB_Ultimate_Parent_Id__c formula to expose 18Char Id. So we need to 
                // to create a different formula for 18 car id based on a stored field popuplated by WF at account creation time
                //string accId15 = ((string)accId).substring(0,15);
                ObjectTerritory2AssignmentRuleItem assignRuleItem = new ObjectTerritory2AssignmentRuleItem(
                //RuleId = assignRule.Id, Field = 'Account.SMB_Ultimate_Parent_Id__c', Operation = 'equals',
                RuleId = assignRule.Id, Field = 'Account.SMB_ACC_Ultimate_Parent_18_Id_F__c', Operation = 'equals',
                Value = accId, sortOrder = 1);
                insert assignRuleItem; 
                
                //Then we associate the rule to the parent territory (terGAM)
                RuleTerritory2Association assocRule = new RuleTerritory2Association(IsInherited = false, RuleId = assignRule.id,
                Territory2Id = terGAM.Id);
                insert assocRule;
                
                //Then we associate the rule to the child territory (ter)
                RuleTerritory2Association assocRule_Read = new RuleTerritory2Association(IsInherited = false, RuleId = assignRule.id,
                Territory2Id = ter.Id);
                insert assocRule_Read;
                
                //We call the @future method to associate all accounts to the territories the first time
                //because the rule is not triggered on creation
                //We need to use @future method to avoid a DML error
                //runRule(accId, terGAM.Id, ter.Id);
                
                //We need to retrieve all users associated to the accounts in the hierarchy in order to
                // link them to the territories
                List<Account> listAcc = [SELECT Id, Name, OwnerId FROM Account WHERE SMB_ACC_Ultimate_Parent_18_Id_F__c =: accId];
                Set<Id> listUserGAM = new Set<Id>();
                Set<Id> listUserNotGAM = new Set<Id>();
                for(Account a : listAcc){
                    if(a.Id == accId)
                        listUserGAM.add(a.OwnerId);
                    else listUserNotGAM.add(a.OwnerId);
                }
                for(AccountTeamMember atm : [SELECT Id, UserId, TeamMemberRole FROM AccountTeamMember WHERE AccountId IN: listAcc]){
                    listUserNotGAM.add(atm.UserId);
                }
                
                //We associate the lists of user with the territories
                List<UserTerritory2Association> listAssocGAM = new List<UserTerritory2Association>();
                List<UserTerritory2Association> listAssocNotGAM = new List<UserTerritory2Association>();
                
                for(Id i : listUserGAM){
                    UserTerritory2Association assocGAM = new UserTerritory2Association(Territory2Id = terGAM.Id,
                    UserId = i);
                    listAssocGAM.add(assocGAM);
                }
                for(Id i : listUserNotGAM){
                    UserTerritory2Association assocNotGAM = new UserTerritory2Association(Territory2Id = ter.Id,
                    UserId = i);
                    listAssocNotGAM.add(assocNotGAM);
                }
                insert listAssocGAM;
                insert listAssocNotGAM;
                
                //We call the @future method to check the territory created field
                //We need to use @future method to avoid a DML error
                checkField(accId, boolCreate);
            }
            
            //boolCreate = false ==> delete of the territory management
            else{
                String terrName = 'Territory_' + accId + '%';
                List<Territory2> listTerr = [SELECT Id FROM Territory2 WHERE DeveloperName LIKE: terrName];
                if(listTerr.size() > 0)
                    database.delete(listTerr, false);
                
                String ruleName = 'Rule_' + accId;
                List<ObjectTerritory2AssignmentRule> listRule = [SELECT Id FROM ObjectTerritory2AssignmentRule WHERE DeveloperName =: ruleName];
                if(listRule.size() > 0)
                    database.delete(listRule, false);
                
                //We call the @future method to uncheck the territory created field
                //We need to use @future method to avoid a DML error
                checkField(accId, boolCreate);
            }
            
            PageReference pageRef = new PageReference('/' + accId + '?retURL=%2F' + accId);
            return pageRef;
        }
        catch(exception ex){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Exception Error: ' + ex));
            return null;
        }
    }
    
    /*@future
    //Method to associate all accounts to the territories the first time
    public static void runRule(String accId, String terGAMId, String terId){
        List<ObjectTerritory2Association> listAssocAcc = new List<ObjectTerritory2Association>();
        for(Account a : [SELECT Id, Name FROM Account WHERE SMB_ACC_Ultimate_Parent_18_Id_F =: accId]){
            ObjectTerritory2Association o = new ObjectTerritory2Association(ObjectId = a.Id,
            Territory2Id = terGAMId, AssociationCause = 'Territory2Manual');
            listAssocAcc.add(o);
            ObjectTerritory2Association o2 = new ObjectTerritory2Association(ObjectId = a.Id,
            Territory2Id = terId, AssociationCause = 'Territory2Manual');
            listAssocAcc.add(o2);
        }
        insert listAssocAcc;
    }*/
    
    @future
    //Method to check or uncheck the Territory Created Field
    public static void checkField(String accId, String boolCreate){
        Account a = [SELECT Id, SMB_ACC_Territory_Created__c FROM Account WHERE Id =: accId limit 1];
        if(boolCreate == 'true')
            a.SMB_ACC_Territory_Created__c = true;
        else a.SMB_ACC_Territory_Created__c = false;
        
        update a;
    }
}