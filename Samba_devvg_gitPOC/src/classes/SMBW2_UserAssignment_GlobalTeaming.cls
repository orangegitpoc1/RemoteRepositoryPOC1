/**
    About
    -----
    Description: .
    Created for: SAMBA
    Create date: DEC 2014
    
    Details / Methods
    -----------------
    This class performs the user assignment to the territories present in the system.
   
    Update History
    --------------
    Updated March 2014 - A.Bhatnagar
    TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
    
    Issues / TODOs
    --------------
Note, the functionality is used like this:
1) Click create global teaming button on a top account
2) Each night
    a)SetupàManageTerritoriesàTerritory Model àView Hierarchy à RUN ALL RULES
    b)Developer Console à DebugàOpen Execute Anonymous Window àSMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories();

What happens:
    -CreateTerritory Class creates the territory and rule
    -Run assign rules maintains list of accounts on the territory (since we don’t use run rule on saving account since account are batch loaded)
    -SMBW2_UserAssignment_GlobalTeaming.assignUsersToTerritories(); maintains list of user on territory
*/
public without sharing class SMBW2_UserAssignment_GlobalTeaming {
    
    //A.T.T.R.I.B.U.T.E.S
    //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
    //public static Set<String> parentAccIdSet = new Set<String>();                                   //Holds the Set of all parent Account Ids for which Global Teaming has been implemented.
    public static Set<ID> parentAccIdSet = new Set<ID>();                                   //Holds the Set of all parent Account Ids for which Global Teaming has been implemented.
    public static List<Account> childAccIdList = new List<Account>();                               //Holds the list of all child Account Ids related to parent Accounts for which Global Teaming has been implemented.
    public static List<AccountTeamMember> accTeamMemberList = new List<AccountTeamMember>();        //Holds list of Account members related to GAM accounts.
    public static Set<Id> childTerritorySet = new Set<Id>();                        //Holds list of all child Territories (NonGAM Territories).
    public static List<UserTerritory2Association> childTerritoryUserAssoList = new List<UserTerritory2Association>();   //Holds list of user-territory association for child territories.
    public static List<UserTerritory2Association> childTerritoryUserAssocNonGAMlist = new List<UserTerritory2Association>();    //Holds new list of user-territory association for child territories(NonGAM Territories).
    public static Set<String> childAccountUserSet = new Set<String>();                                      //Holds Account ownerId of the Child Accounts(Non GAM Accounts)
    public static Set<Id> userGAMSet = new Set<Id>();                                                               //Holds Set of GAM users.
    public static Set<Id> ParentTerritorySet = new Set<Id>();                                       //Holds list of all parent Territories (GAM Territories).
    //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
    //public static Map<String,Id> gAMAccIdTogAMUserIdMap= new Map<String,Id>();
    public static Map<Id,Id> gAMAccIdTogAMUserIdMap= new Map<Id,Id>();
    public static List<UserTerritory2Association> parentTerritoryUserAssoList = new List<UserTerritory2Association>();          //Holds list of user-territory association for parent territories(GAM Territories).
    public static List<UserTerritory2Association> parentTerritoryUserAssocGAMlist = new List<UserTerritory2Association>();  //Holds new list of user-territory association for Parent territories(GAM Territories).
    //A.T.T.R.I.B.U.T.E.S
    
    
    //1. This Method assign users to the respective territories.
    public static void assignUsersToTerritories(){
        
        for(Account acc : [Select a.Id,a.OwnerId,a.SMB_ACC_Territory_Created__c From Account a Where a.SMB_ACC_Territory_Created__c = true AND a.Id!='001E000000wdYOO']){
            
            //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
            //gAMAccIdTogAMUserIdMap.put(String.ValueOf(acc.Id).substring(0, 15),acc.OwnerId);
            gAMAccIdTogAMUserIdMap.put(acc.Id,acc.OwnerId);
            userGAMSet.add(acc.OwnerId);
            //parentAccIdSet.add((String.ValueOf(acc.Id).substring(0, 15)));
            parentAccIdSet.add((id)acc.Id);
        }
        system.debug('======> parentAccIdSet.size():' + parentAccIdSet.size() + ' ' + parentAccIdSet);
        childTerritoriesUserAssignment(true);
        parentTerritoriesUserAssignment(true);
    }

    //Splitting assignUsersToTerritories into assignUsersToTerritories1 and assignUsersToTerritories2 to process less records and avoid Limit Exception
    public static void assignUsersToTerritories1(){
        
        for(Account acc : [Select a.Id,a.OwnerId,a.SMB_ACC_Territory_Created__c From Account a Where a.SMB_ACC_Territory_Created__c = true AND a.Id!='001E000000wdYOO' AND a.name<='K']){
            
            //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
            //gAMAccIdTogAMUserIdMap.put(String.ValueOf(acc.Id).substring(0, 15),acc.OwnerId);
            gAMAccIdTogAMUserIdMap.put(acc.Id,acc.OwnerId);
            userGAMSet.add(acc.OwnerId);
            //parentAccIdSet.add((String.ValueOf(acc.Id).substring(0, 15)));
            parentAccIdSet.add((id)acc.Id);
        }
        system.debug('======> parentAccIdSet.size():' + parentAccIdSet.size() + ' ' + parentAccIdSet);
        childTerritoriesUserAssignment(true);
        parentTerritoriesUserAssignment(true);
    }
    
    //Splitting assignUsersToTerritories into assignUsersToTerritories1 and assignUsersToTerritories2 to process less records and avoid Limit Exception
    public static void assignUsersToTerritories2(){
        
        for(Account acc : [Select a.Id,a.OwnerId,a.SMB_ACC_Territory_Created__c From Account a Where a.SMB_ACC_Territory_Created__c = true AND a.Id!='001E000000wdYOO' AND a.name>'K']){
            
            //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
            //gAMAccIdTogAMUserIdMap.put(String.ValueOf(acc.Id).substring(0, 15),acc.OwnerId);
            gAMAccIdTogAMUserIdMap.put(acc.Id,acc.OwnerId);
            userGAMSet.add(acc.OwnerId);
            //parentAccIdSet.add((String.ValueOf(acc.Id).substring(0, 15)));
            parentAccIdSet.add((id)acc.Id);
        }
        system.debug('======> parentAccIdSet.size():' + parentAccIdSet.size() + ' ' + parentAccIdSet);
        childTerritoriesUserAssignment(false);
        parentTerritoriesUserAssignment(false);
    }
    
    //2. Assigns users to all NonGAM Territories.
    public static void childTerritoriesUserAssignment(boolean deleteAlso){
        
        Map<String,Territory2> nonGAMTerrNameToTerrMap = new Map<String,Territory2>();
        
        //Getting all the Child records related to Parents.
        //TKT-2172 OLM 15/3/26 manage ids on 18char to avoid account-territory name collision (AXA and BPCE had same id on 15 char insensitive)
        childAccIdList = [Select a.Id,a.OwnerId,a.SMB_ACC_Ultimate_Parent_18_Id_F__c //SMB_Ultimate_Parent_Id__c 
                          From Account a Where a.SMB_ACC_Ultimate_Parent_18_Id_F__c IN:parentAccIdSet];
        //system.debug('======> childAccIdList.size():' + childAccIdList.size());
        
        //Getting the Child Territories.
        for(Territory2 t: [Select t.Name, t.Id, t.DeveloperName From Territory2 t Where t.DeveloperName Like: '%Read']){
            
            nonGAMTerrNameToTerrMap.put(t.DeveloperName,t);
            childTerritorySet.add(t.Id);
        }
        
        if (deleteAlso) {
            //Deleting the User Association of the Child Territories.
            childTerritoryUserAssoList = [Select u.Territory2Id, u.Id From UserTerritory2Association u Where u.Territory2Id IN:childTerritorySet];
            delete childTerritoryUserAssoList;                  //Deleting all the users assigned to child Territories(NonGAM Terriories).
        }
        
        for(AccountTeamMember a :[Select a.User.Username, a.UserId, a.Account.SMB_ACC_Ultimate_Parent_18_Id_F__c, a.AccountId,a.Account.OwnerId, 
                                    a.AccountAccessLevel From 
                                    AccountTeamMember a
                                     Where a.AccountId IN:childAccIdList]){
                                        
            //TKT-2172 OLE: cast a.account.SMB_Ultimate_Parent_Id__c with (id) to force 18 char id
            if(nonGAMTerrNameToTerrMap.containsKey('Territory_'+ (id) a.account.SMB_ACC_Ultimate_Parent_18_Id_F__c +'_Read')){
                String key1 ='';
                String key2 ='';
                
                //TKT-2172 cast first to (id) to force 18, then to string to allow concatenation with into string.
                key1 = (string)(id) a.account.SMB_ACC_Ultimate_Parent_18_Id_F__c + a.Account.OwnerId;
                key2 = (string)(id) a.account.SMB_ACC_Ultimate_Parent_18_Id_F__c + a.UserId;
                
                if(!childAccountUserSet.contains(key1)){
                    //UserTerritory2Association assocNonGAMAccOwner = new UserTerritory2Association(Territory2Id = nonGAMTerrNameToTerrMap.get('Territory_'+a.account.SMB_Ultimate_Parent_Id__c +'_Read').Id, UserId = a.Account.OwnerId);
                    UserTerritory2Association assocNonGAMAccOwner = new UserTerritory2Association(Territory2Id = nonGAMTerrNameToTerrMap.get('Territory_'+ (id) a.account.SMB_ACC_Ultimate_Parent_18_Id_F__c +'_Read').Id, UserId = a.Account.OwnerId);
                    childTerritoryUserAssocNonGAMlist.add(assocNonGAMAccOwner);
                    childAccountUserSet.add(key1);
                    //system.debug('================> adding key1: ' + key1);
                }
                if(!childAccountUserSet.contains(key2)){
                    UserTerritory2Association assocNotGAM = new UserTerritory2Association(Territory2Id = nonGAMTerrNameToTerrMap.get('Territory_'+ (id) a.account.SMB_ACC_Ultimate_Parent_18_Id_F__c +'_Read').Id, UserId = a.UserId);
                    childTerritoryUserAssocNonGAMlist.add(assocNotGAM);
                    childAccountUserSet.add(key2);
                    //system.debug('================> adding key2: ' + key2);
                }
            }
            
        }
        
        for(Account acc:childAccIdList){
            //a.account.SMB_Ultimate_Parent_Id__c
            String key3 ='';
            key3 = (string)(id) acc.SMB_ACC_Ultimate_Parent_18_Id_F__c + acc.OwnerId;
            if(nonGAMTerrNameToTerrMap.containsKey('Territory_'+(id) acc.SMB_ACC_Ultimate_Parent_18_Id_F__c +'_Read')){
                if(!childAccountUserSet.contains(key3)){
                    UserTerritory2Association assocNonGAMAccOwner1 = new UserTerritory2Association(Territory2Id = nonGAMTerrNameToTerrMap.get('Territory_'+ (id) acc.SMB_ACC_Ultimate_Parent_18_Id_F__c +'_Read').Id, UserId = acc.OwnerId);
                    childTerritoryUserAssocNonGAMlist.add(assocNonGAMAccOwner1);
                    childAccountUserSet.add(key3);
                    //system.debug('================> adding key3: ' + key3);
                }
            }
        }
        insert childTerritoryUserAssocNonGAMlist;
        //system.debug('=========> childTerritoryUserAssocNonGAMlist: ' + childTerritoryUserAssocNonGAMlist);
    } 
    
    
    //3. Assigns users to all GAM Territories.
    public static void parentTerritoriesUserAssignment(boolean deleteAlso){
        
        Map<String,Territory2> gAMTerrNameToTerrMap = new Map<String,Territory2>();
        
        for(Territory2 t: [Select t.Name, t.Id, t.DeveloperName From Territory2 t Where NOT t.DeveloperName Like: '%Read']){
            
            gAMTerrNameToTerrMap.put(t.DeveloperName,t);
            ParentTerritorySet.add(t.Id);
        }
        
        if (deleteAlso) {
            parentTerritoryUserAssoList =[Select u.Territory2Id, u.Id From UserTerritory2Association u Where u.Territory2Id IN:ParentTerritorySet];
            delete parentTerritoryUserAssoList;                 //Deleting all the users assigned to parent Territories(NonGAM Terriories).
        }
        
        for(String acc:gAMAccIdTogAMUserIdMap.keySet()){
                                                
            if(gAMTerrNameToTerrMap.containsKey('Territory_'+acc)){
                UserTerritory2Association assocGAM = new UserTerritory2Association(Territory2Id = gAMTerrNameToTerrMap.get('Territory_'+acc).Id, UserId = gAMAccIdTogAMUserIdMap.get(acc));
                parentTerritoryUserAssocGAMlist.add(assocGAM);
            }
        }
        insert parentTerritoryUserAssocGAMlist;
    }
    
}