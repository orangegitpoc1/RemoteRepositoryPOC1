/* Created For Ust -1270 Assigning Marketing Manager bases on owner's cluster and region
   we have created a custom setting Lead Marketing Manager Mapping for mapping of marketing manager bases on cluster and region 
   Developed by dev support 
 */  
public Class SMB_LeadManagerMapping
{
    public static Boolean runOnlyOnce = true;
    public static Boolean runOnlyOncebefore= true;
    Map<string,string> clusterWithManagerid=new map<String,String>();
    Map<id,User>Mapuser= new Map<id,user>();
    Map<id,String> QueueMap=new Map<id,String>();
    User Usr;
    Set<id>ids=new set<id>();
    Map<Id,id> leadStatus = new Map<Id,id>(); // Map of the converted Account ID and the Lead ownerid
    Map<Id,id> leadStatusContact = new Map<Id,id>(); // Map of the converted Contact ID and the Lead ownerid

        public void insertMarketingManager(List<lead>Newlead){
         try{
             LeadMarketingManagermapping();// get custom setting data 
             Mapofuser(newLead);  // map of user 
                for(Lead ld:Newlead){
                 
                       if(ld.Marketing_Manager__c==null && ld.Ownerid!=null ) {
                      //   system.debug('mapuser.get(ld.Ownerid).SMB_Sales_Cluster__c'+mapuser.get(ld.Ownerid).SMB_Sales_Cluster__c);
                      //   system.debug('clusterWithManagerid.get(mapuser.get(ld.Ownerid).SMB_Sales_Cluster__c)'+clusterWithManagerid.get(mapuser.get(ld.Ownerid).SMB_Sales_Cluster__c));
                        // logic to assign marketing manager 
                            Logic_of_Cluster(ld);
                            
                          }
                      }
                      runOnlyOnce=false; 
           }
            
          catch(Exception e){
            for(lead ld:Newlead){
             ld.addError(e);
           }
        
          }
        }
       
         public  void UpdateMarketingManager(Map<id,lead>NewMaplead,Map<id,lead>OldMaplead,list<lead>newlead,list<lead> Oldlead){
             try{ 
              for(lead ld:newlead){
                if(!ld.IsConverted){
                    if(NewMaplead.get(ld.id).Ownerid!=OldMaplead.get(ld.id).ownerid){
                          if(!(String.valueof(ld.Ownerid).startsWith('00G'))){
                                  LeadMarketingManagermapping();
                                  Mapofuser(newlead);
                                  system.debug('mapuser.get(ld.Ownerid).SMB_Sales_Cluster__c'+mapuser.get(ld.Ownerid).SMB_Sales_Cluster__c);
                                   system.debug('DDDDDDDDDDDDDDDDDD'+mapuser.get(ld.Ownerid).SMB_Sales_Region__c+' '+'Region');
                                   Logic_of_Cluster(ld); 
                                  
                           }
                           if((String.valueof(ld.Ownerid).startsWith('00G'))){
                            LeadMarketingManagermapping();
                            Map_of_Queue_Id();
                            String name_Queue=QueueMap.get(ld.Ownerid);
                            if(name_Queue=='Switzerland'){
                              name_Queue='CH';
                            }
                            if(name_Queue=='UK & Ireland'){
                              name_Queue='UK & I';
                            }
                            
                          //  system.debug('name_Queue'+name_Queue);
                          //  system.debug('clusterWithManagerid.get(name_Queue)'+clusterWithManagerid.get(name_Queue));
                                if(clusterWithManagerid.get(name_Queue)!=null){
                                   
                                    ld.Marketing_Manager__c=clusterWithManagerid.get(name_Queue);
                                    system.debug('ld.Marketing_Manager__c'+ld.Marketing_Manager__c);
                                }
                                system.debug('clusterWithManagerid.get(name_Queue)'+clusterWithManagerid.get(name_Queue+' '+'Region'));
                                if(clusterWithManagerid.get(name_Queue)==null && clusterWithManagerid.get(name_Queue+' '+'Region')!=null){
                                   ld.Marketing_Manager__c=clusterWithManagerid.get(name_Queue+' '+'Region'); 
                                }
                               if(clusterWithManagerid.get(name_Queue)==null && clusterWithManagerid.get(name_Queue+' '+'Region')==null){
                                   ld.Marketing_Manager__c=clusterWithManagerid.get('Default'); 
                                }
                           } 
                          runOnlyOncebefore=false;    
                      }              
                }
                  else{
                    for(Lead led : newlead) {
                            if (led.IsConverted) {
                                leadStatus.put(led.ConvertedAccountId,led.Ownerid);
                                leadStatusContact.put(led.ConvertedContactId,led.Ownerid);
                                
                            }
                        }
                        UpdateAccountMarketingManager_Afterleadconvert(leadStatus);
                        UpdateContactOwnerEmailTextNameText(leadStatusContact);
                      }
               } 
            }
            
            catch(Exception e) {
               for(lead ld:Newlead){
                ld.addError(e);
              }
            }
         }
         // update  contact marketing manager email text and name text
        @future
        public static void UpdateContactOwnerEmailTextNameText(Map<Id,id> leadStatuscon){
          List<Contact> ConContact = [select Id,ownerid,owner.Email,Owner.firstName,Owner.lastName from Contact WHERE Id IN :leadStatuscon.keySet()];
            for(contact co:ConContact){
              co.Contact_Owner_Email_Text__c= co.owner.Email;
              co.Contact_Owner_Name_Text__c= co.Owner.firstName+''+co.Owner.lastName;
            
            }
            try{
            Update ConContact;
            }
            Catch(Exception e){}
                       
        
        }
     
       @future 
        public static void UpdateAccountMarketingManager_Afterleadconvert(Map<Id,id> leadStatus){
             try{ 
                   SMB_AccountManagerMapping Samm =new SMB_AccountManagerMapping();
                   system.debug('leadStatus'+leadStatus);
                        List<Account> accAccount = [select Id,ownerid,Marketing_Manager__c from account WHERE Id IN :leadStatus.keySet()];
                        system.debug('accAccount22'+accAccount);
                        Map<id,User> Mapuser=Samm.Mapofuser(accAccount);
                        Map<string,string> clusterWithManagerid= Samm.AccountMarketingManagermapping();
                            for (Account ac : accAccount) {
                                   system.debug('Marketing_Manager__c2333'+ac.Marketing_Manager__c);
                                   system.debug('ownerid3232'+ac.ownerid);
                                //    ac.Marketing_Manager__c  = leadStatus.get(ac.Id);
                                if(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c!=null)
                                   {
                                           
                                            if(clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c)!=null){
                                                 Ac.Marketing_Manager__c=clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c);
                                            }
                                            if(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c==null && mapuser.get(Ac.Ownerid).SMB_Sales_Region__c!=null && clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c+' '+'Region')!=Null)
                                              {
                                                 
                                                 Ac.Marketing_Manager__c=clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c+' '+'Region');
                                                                    
                                               }                        
                                           if(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c==null && clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c+' '+'Region')==null)
                                              {
                                              
                                                Ac.Marketing_Manager__c=clusterWithManagerid.get('Default');
                                          
                                              } 
                                        }
                                if(mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c=='N/A'||mapuser.get(AC.Ownerid).SMB_Sales_Cluster__c==''||mapuser.get(Ac.Ownerid).SMB_Sales_Cluster__c==NULL)
                                  {
                                     
                                     if(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c!=null && clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c+' '+'Region')!=Null)
                                       {
                                       
                                        Ac.Marketing_Manager__c=clusterWithManagerid.get(mapuser.get(Ac.Ownerid).SMB_Sales_Region__c +' '+'Region');
                                                                 
                                         }                      
                                       else
                                         {
                                         
                                          Ac.Marketing_Manager__c=clusterWithManagerid.get('Default');
                                          
                                       
                                         } 
                                   }
                                   system.debug('Ac.Marketing_Manager__c'+Ac.Marketing_Manager__c);
                                }
                                
                               update accAccount;
                }  
                catch(Exception e){
                  
            }         
        }
        public void Logic_of_Cluster(lead ld){
                      if(mapuser.get(ld.Ownerid).SMB_Sales_Cluster__c!='N/A'||mapuser.get(ld.Ownerid).SMB_Sales_Cluster__c!=null){
                                
                                if(clusterWithManagerid.get(mapuser.get(ld.Ownerid).SMB_Sales_Cluster__c)!=null) {
                                        ld.Marketing_Manager__c=clusterWithManagerid.get(mapuser.get(ld.Ownerid).SMB_Sales_Cluster__c);
                                        ld.Lead_Owner_Name_Text__c=Mapuser.get(ld.Ownerid).FirstName+''+Mapuser.get(ld.Ownerid).LastName;
                                        ld.Lead_Owner_Email_Text__c=Mapuser.get(ld.Ownerid).email;
                                        }
                                if(clusterWithManagerid.get(mapuser.get(ld.Ownerid).SMB_Sales_Cluster__c)==null && mapuser.get(ld.Ownerid).SMB_Sales_Region__c!=null && clusterWithManagerid.get(mapuser.get(ld.Ownerid).SMB_Sales_Region__c+' '+'Region')!=null)
                                {
                                     
                                        ld.Marketing_Manager__c=clusterWithManagerid.get(mapuser.get(ld.Ownerid).SMB_Sales_Region__c+' '+'Region');
                                        ld.Lead_Owner_Name_Text__c=Mapuser.get(ld.Ownerid).FirstName+''+Mapuser.get(ld.Ownerid).LastName;
                                        ld.Lead_Owner_Email_Text__c=Mapuser.get(ld.Ownerid).email;
                                
                                }                       
                                if(clusterWithManagerid.get(mapuser.get(ld.Ownerid).SMB_Sales_Cluster__c)==null  && clusterWithManagerid.get(mapuser.get(ld.Ownerid).SMB_Sales_Region__c+' '+'Region')==null)
                                {
                                          ld.Marketing_Manager__c=clusterWithManagerid.get('Default');
                                          ld.Lead_Owner_Name_Text__c=Mapuser.get(ld.Ownerid).FirstName+''+Mapuser.get(ld.Ownerid).LastName;
                                          ld.Lead_Owner_Email_Text__c=Mapuser.get(ld.Ownerid).email;
                                       
                                } 
                            }
                            if(mapuser.get(ld.Ownerid).SMB_Sales_Cluster__c==null){
                               
                                if(mapuser.get(ld.Ownerid).SMB_Sales_Region__c!=null && clusterWithManagerid.get(mapuser.get(ld.Ownerid).SMB_Sales_Region__c+' '+'Region')!=Null)
                                {
                                       system.debug('5');
                                        ld.Marketing_Manager__c=clusterWithManagerid.get(mapuser.get(ld.Ownerid).SMB_Sales_Region__c+' '+'Region');
                                        ld.Lead_Owner_Name_Text__c=Mapuser.get(ld.Ownerid).FirstName+''+Mapuser.get(ld.Ownerid).LastName;
                                        ld.Lead_Owner_Email_Text__c=Mapuser.get(ld.Ownerid).email;
                                
                                }                       
                                       else
                                       {
                                          ld.Marketing_Manager__c=clusterWithManagerid.get('Default');
                                          ld.Lead_Owner_Name_Text__c=Mapuser.get(ld.Ownerid).FirstName+''+Mapuser.get(ld.Ownerid).LastName;
                                          ld.Lead_Owner_Email_Text__c=Mapuser.get(ld.Ownerid).email;
                                       
                                       } 
                            }
                            
        
        }
        
        public void Mapofuser(List<lead>Newlead){
           list<User> listuser;
           try{
              for(Lead ld:Newlead){
                 
                  ids.add(ld.ownerid);
                } 
                
                system.debug('ld.ownerid'+ids); 
                  listuser=[select id,SMB_Sales_Region__c,SMB_Sales_Cluster__c,firstname,lastname,email FROM User where id in:ids];
              
             
            if(listuser.size()>0){  
              for(user us:listuser)  
               {
                  Mapuser.put(us.id,us); 
               } 
            }
            }
            catch(Exception e){
             for(lead ld:Newlead){
                 ld.addError(e);
             }
            
            }
            
    
        }
           
        public void LeadMarketingManagermapping(){
          try{
            List<Lead_Marketing_Manager_Mapping__c> LMMM=[select Name,Marketing_Manager_Id__c,Marketing_Manager_Name__c from Lead_Marketing_Manager_Mapping__c];
                for(Lead_Marketing_Manager_Mapping__c LM:LMMM){
                    clusterWithManagerid.put(LM.Name,LM.Marketing_Manager_Id__c);
                  }
           }
           catch(Exception e){
                  
            }
        }
        public void Map_of_Queue_Id(){
            List<QueueSobject> Queue_Id=[SELECT Id,Queue.name,QueueId,SobjectType FROM QueueSobject WHERE SobjectType = 'lead'];
              for(QueueSobject Qs:Queue_Id){
                QueueMap.put(Qs.QueueId,Qs.Queue.name);
              }
        }
        
  }