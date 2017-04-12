public class UserTriggerHandler{

    public static void onBeforeUpdate(List<User> oldUsers, List<User> newUsers, 
                                    Map<ID, User> oldUserMap, Map<ID, User> newUserMap){
        if (PAD.canTrigger('UserTriggerHandler.clearOBSManager')){
            clearOBSManager(oldUsers, newUsers, oldUserMap, newUserMap);
        }
    }
    
    public static void clearOBSManager(List<User> oldUsers, List<User> newUsers, 
                                Map<ID, User> oldUserMap, Map<ID, User> newUserMap){
        List<Id> usrIdsDeactivating=new List<Id>();
        for (User usr: newUsers){
            if ( !(usr.IsActive) && oldUserMap.get(usr.id).IsActive) {
                usrIdsDeactivating.add(usr.id);
            }
        }
        
        List<User> childUsers = [Select id, name, email,  OBS_Manager__c, OBS_Manager__r.name, SMB_Sales_Region__c, Profile.Name from User where OBS_Manager__c IN : usrIdsDeactivating];
        //[ OR (SMB_Sales_Region__c  IN : usrIdsDeactivatingRegions.values() AND Profile.Name='Regional Administrator User SAMBA')]; //Querying both children and Regional Admins to execute only 1 query instead of 2.
        List<User> toUpdate=new List<User>();
        
        List<String> regions=new List<String>();
        Map<String, String> regionContentMap=new Map<String, String>();//Region, content of email
        Map<String, String> regionEmail= new Map<String, String>();//Region, email in To (where content of email in above Map will be sent)
        Map<String, String> regionOBSManager = new Map<String, String>();//Region, Name of OBS Manager
        
        for (User usr: childUsers){
                                  If (!regionContentMap.keySet().contains(usr.SMB_Sales_Region__c))    {
                                         //String emailContent= 'Hi,\n User '+ usr.OBS_Manager__r.name +'('+System.URL.getSalesforceBaseUrl().toExternalForm() +'/'+usr.OBS_Manager__c+')' + ' OBS Manager of below users has been deactivated.' +
                                         String emailContent= 'Dear Regional Admin,\n' +'\n'+
                                         'In SAMBA,below OBS Manager(s) has just been deactivated which has impacted the following user(s).\n'+'\n'+
                                         'The OBS Manager name is now set to the BLANK for the below list of user(s):'+'\n'+
                                          '\n' +'User Name     : OBS Manager'+'\n'+'\n'+ usr.name + '    '+':'+'  '+usr.OBS_Manager__r.name +'\n'  ;
                                         regionContentMap.put(usr.SMB_Sales_Region__c, emailContent);
                                         regionOBSManager.put(usr.SMB_Sales_Region__c, usr.OBS_Manager__r.name);
                                  } else {
                                         regionContentMap.put(usr.SMB_Sales_Region__c, regionContentMap.get(usr.SMB_Sales_Region__c) +
                                         '\n' +usr.name + '    '+':'+'  '+usr.OBS_Manager__r.name +'\n'
                                             );
                                  }
                                  usr.OBS_Manager__c=null;
                                  toUpdate.add(usr);
        }
        
        List<User> regUsers = [Select id, name, email,  OBS_Manager__c, SMB_Sales_Region__c, Profile.Name,isactive from User where SMB_Sales_Region__c IN : regionContentMap.keySet() AND Profile.Name='Regional Administrator User SAMBA'AND isactive=true];
        
        for (User usr: regUsers){
                        If (!regionEmail.keySet().contains(usr.SMB_Sales_Region__c) && (usr.Profile.Name=='Regional Administrator User SAMBA')){
                                        regionEmail.put(usr.SMB_Sales_Region__c, usr.email);
                        } else {
                            regionEmail.put(usr.SMB_Sales_Region__c, regionEmail.get(usr.SMB_Sales_Region__c)+','+usr.email);
                        }
        }
        
        System.debug('regionEmail:'+regionEmail);
        System.debug('regionContentMap:'+regionContentMap);
        
        //To Send emails
        SMB_clearOBSManager_Helper.sendEmails(regionEmail, regionContentMap, regionOBSManager);
        
        Update toUpdate;
    }

}