/* Created For Ust -1270 Assigning Marketing Manager bases on owner's cluster and region
   we have created a custom setting Lead Marketing Manager Mapping for mapping of marketing manager bases on cluster and region 
   Developed by dev support 
 */  
public Class SMB_AccountManagerMapping{
    Map<string,string> clusterWithManagerid=new map<String,String>(); // get data in map of custom setting (Lead_Marketing_Manager_Mapping__c)
    Map<id,User>Mapuser= new Map<id,user>();  // map of account owner's cluster and owner id 
    User Usr;
    Set<id>ids=new set<id>();
    public static Boolean runOnlyOnce = true;
    public static Boolean runOnlybeforeOnce = true;
    public static Boolean runOnlyafterOnce = true;
    
   // Method to insert Marketing manager automatically bases on Account Owner's cluster
   // Two maps created "clusterWithManagerid" and "Mapuser" to get relational data from account owner cluster and predefine list in custom setting(Lead_Marketing_Manager_Mapping__c) .
        public void insertMarketingManager(List<Account>NewAccount){
         try{
         AccountMarketingManagermapping(); //get value of custom setting in Map
         Mapofuser(NewAccount);  //map with userid and user
                for(Account Ac: NewAccount){
                  system.debug('Mapuser'+Mapuser);
                  
              // Logic of assigning marketing manager    
                  
                  if(Ac.Marketing_Manager__c==null)
                  {
                    if(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c!='N/A'||mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c!=NULL)
                    {
                        if(clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c)!=null){
                       
                             Ac.Marketing_Manager__c=clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c);
                        }
                        if(clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c)==null && mapuser.get(Ac.Ownerid).SMB_Sales_Region__c!=null && clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c+' '+'Region')!=Null)
                        {
                              Ac.Marketing_Manager__c=clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c+' '+'Region');
                        }
                       if(clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c)==null  && clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c+' '+'Region')==null)
                           {
                               
                                   Ac.Marketing_Manager__c=clusterWithManagerid.get('Default');
                            }
                    }
                    if(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c=='N/A'||mapuser.get(AC.Ownerid).SMB_Sales_Cluster__c==''||mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c==NULL)
                    {
                       
                        if(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c!=null && clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c+' '+'Region')!=null ){
                               Ac.Marketing_Manager__c=clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c+' '+'Region');
                        }
                            else{
                                   Ac.Marketing_Manager__c=clusterWithManagerid.get('Default');
                            }
                    }
                     runOnlyOnce=false;
                  }
                  
                  
              }
           }
           catch(Exception e){
             for(Account Ac: NewAccount){
               Ac.addError(e);
             }
           }
        }
        
   // Method to Update Marketing manager automatically bases on Account Owner's cluster
   // Two maps created "clusterWithManagerid" and "Mapuser" to get relational data from account owner cluster and predefine list in custom setting(Lead_Marketing_Manager_Mapping__c) .
        
         public void UpdateMarketingManager(Map<id,Account>NewMapAccount,Map<id,Account>OldMapAccount,list<Account>newAccount,list<Account> OldAccount){
            try{ 
                  AccountMarketingManagermapping();  //get value of custom setting in Map
                  Mapofuser(newAccount);             //map with userid and user
                      for(Account Ac:newAccount){
                          
                          if(NewMapAccount.get(Ac.id).Ownerid!=OldMapAccount.get(Ac.id).ownerid){
                               
                            if(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c!='N/A'||mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c!=NULL)
                             {
                                if(clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c)!=null){
                                     Ac.Marketing_Manager__c=clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c);
                                }
                                  if(clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c)==null && mapuser.get(Ac.Ownerid).SMB_Sales_Region__c!=null && clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c+' '+'Region')!=null ){
                                       Ac.Marketing_Manager__c=clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c+' '+'Region');
                                }
                                    if(clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c)==null  && clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c+' '+'Region')==null ){
                                     
                                           Ac.Marketing_Manager__c=clusterWithManagerid.get('Default');
                                    }
                             }
                            if(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c=='N/A'||mapuser.get(AC.Ownerid).SMB_Sales_Cluster__c==''||mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c==NULL)
                            {
                                if(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c!=null && clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c+' '+'Region')!=null ){
                                       Ac.Marketing_Manager__c=clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c+' '+'Region');
                                }
                                    else{
                                           Ac.Marketing_Manager__c=clusterWithManagerid.get('Default');
                                    }
                            }
                             runOnlybeforeOnce =false;      
                          }              
                      }
            } 
            
            catch(Exception e){
               for(Account Ac: NewAccount){
               Ac.addError(e);
             }
            }
            
         }
      // Update all contact of account because marketing manager email text and name text field are in contact not in account  
       
          public void UpdateContactMarketingEmail_Name_Text(Map<id,Account>NewMapAccount,Map<id,Account>OldMapAccount,list<Account>newAccount,list<Account> OldAccount)
          {
              
              set<id> ids=new set<id>();
              set<id> Userid=new set<id>();
              Map<id,List<contact>> Accountid_contact=new Map<id,List<contact>>();
              List<Contact> listcon=new List<Contact>(); 
               
              for(Account ac : newAccount)
              {
                 system.debug('ac.Marketing_Manager__c'+ac.Marketing_Manager__c);
                 system.debug('OldMapAccount.get(ac.id).Marketing_Manager__c'+OldMapAccount.get(ac.id).Marketing_Manager__c); 
                 //ac.Marketing_Manager__c!=OldMapAccount.get(ac.id).Marketing_Manager__c &&
                 if(ac.Marketing_Manager__c!=null)
                 {
                   ids.add(ac.id);
                   Userid.add(ac.Marketing_Manager__c);
                 }
              
              } 
              system.debug('ids'+ids+'Userid'+Userid);
              Map<id,User> MapUser=new Map<id,User>([Select id, name,Email from user where id In:Userid]);
              List<Contact> con=[Select id,AccountId,Marketing_Manager_Email_Text__c,Marketing_Manager_Name_Text__c,Ownerid,owner.firstName,owner.lastName,owner.Email from contact where AccountId In:ids ];
              system.debug('MapUser'+MapUser);
              system.debug('con'+con);        
                if(con.size()>0)
                {   
                  for(Contact c:con)
                          {
                               if(Accountid_contact.containsKey(c.Accountid))
                               {
                                 list<contact> cont =Accountid_contact.get(c.Accountid); 
                                 cont.add(c);  
                                 Accountid_contact.put(c.Accountid,cont);
                               }
                               else
                               {
                                 Accountid_contact.put(c.Accountid,new list<contact>{c});
                               
                               }
                          
                          
                          }        
                
                for(Id idAccount : ids)
                {
                  list<contact> Cont=Accountid_contact.get(idAccount);
                   if(Cont!=null){
                      for(Contact Contt:Cont )
                      {
                         Contt.Marketing_Manager_Email_Text__c=MapUser.get(NewMapAccount.get(idAccount).Marketing_Manager__c).Email;
                         Contt.Marketing_Manager_Name_Text__c =MapUser.get(NewMapAccount.get(idAccount).Marketing_Manager__c).Name;
                       //  Contt.Contact_Owner_Email_Text__c= Contt.owner.email;
                      //   Contt.Contact_Owner_Name_Text__c=Contt.owner.firstName + Contt.owner.lastName;
                         listcon.add(Contt); 
                      }
                   }
                }
              }  
                if(listcon.size()>0)
                {
                  try{
                      Update listcon;
                  }
                  Catch(Exception e){
                    System.debug(e);
                  }
                
                }
              runOnlyafterOnce = false;          
          }
         
        
  //   Get custom setting(Lead_Marketing_Manager_Mapping__c) data in map with cluster name and marketing manager id    
        public Map<string,string> AccountMarketingManagermapping(){
            try{
            List<Lead_Marketing_Manager_Mapping__c> LMMM=[select Name,Marketing_Manager_Id__c,Marketing_Manager_Name__c from Lead_Marketing_Manager_Mapping__c];
                for(Lead_Marketing_Manager_Mapping__c LM:LMMM){
                    clusterWithManagerid.put(LM.Name,LM.Marketing_Manager_Id__c);
                  }
                  return clusterWithManagerid;
             }
             catch(Exception e){
               return null;
             }
        }
    //   Get Account owner id and user data in map     
        public Map<id,User> Mapofuser(List<Account>NewAccount){
            try{
              for(Account Ac:NewAccount){
                  ids.add(Ac.ownerid);
               }   
                  list<User> listuser=[select id,SMB_Sales_Region__c,SMB_Sales_Cluster__c,Name,Email FROM User where id in:ids];
              for(user us:listuser)  
               {
                  Mapuser.put(us.id,us); 
               } 
               
               return Mapuser;
        
        
       }
       catch(Exception e){
         for(Account Ac:NewAccount){
             Ac.addError(e);
             
         }return null;
        }
    }
}