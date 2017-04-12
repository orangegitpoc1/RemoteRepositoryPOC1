/*
Created By Sushant (Dev Support)
Ust-1256 and ust-1235
In this ust we have to share action plan with team member of account and account hierarchy  account owner and team member like Account territory management 
We have created global class and webservice method to call it from custom button present in account pagelayout "Assign Action Plan" This class is called from batch class :SMB_BatchActionPlan_Share and trigger afterinsert_ActionPlan
*/
global class SMB_BatchActionPlan {
    
    // Checkbatch boolean variable is use to check code running from trigger of action plan or through batch apex 
     
    webService static void Exceutebatch(list<Action_plan__c> Ac,Boolean checkbatch)
    {
        Map<Id,list<AccountTeamMember>> acc_with_map =new map<Id,list<AccountTeamMember>>(); // Map to get ultimate account id (which is formula field ) and list of team member
        Map<id,list<Account>> acc_ultimate =new map<id,list<Account>>();// map of utimate account id and list of account associated with it 
        Map<id,id> accid_ultimateParent_id =new Map<id,id>(); //map of account id and ultimate account id 
        Map<id,id> actionPlanShareMap=new Map<id,id>();
        Set<id>acc_ulimateparentids=new set<id>();
        List<Action_Plan__share> Actionplanshare=new list<Action_Plan__share>(); 
        List<Action_Plan__share > OwnerShare= new list<Action_Plan__share>();       
        Set<id> ids=new set<id>();
        Set<id> All_account_id=new set<id>();
        Set<id> Action_plan_Accountid=new set<id>();
              for(Action_plan__c a:Ac){
                 ids.add(a.id);
                 Action_plan_Accountid.add(a.SMB_AP_Account__c);// set of account id to get ultimate parent account id
              }
              system.debug('ids'+ids);
              system.debug('Action_plan_Accountid'+Action_plan_Accountid);
              // if loop will work if we called it from batch or button click 
              if(checkbatch){      
                  list<Action_Plan__share> APshare=[Select ParentId,RowCause,UserOrGroupId,AccessLevel from Action_Plan__share where ParentId IN:ids and RowCause!='Owner'];
                  system.debug('APshare'+APshare);
                     if(APshare.size()>0){
                       try{
                         Database.delete(APshare,false); // delete all action share 
                       }
                       Catch(DMLException e){
                         system.debug('catch'+e);            
                       }
                     
                     }
                } 
                list<Account> All_account=[select id,SMB_ACC_Ultimate_Parent_18_Id_F__c from account where id In:Action_plan_Accountid]; // to get list of ultimateparentaccount id 
                    for(Account act: All_account)
                    {
                      acc_ulimateparentids.add((id)act.SMB_ACC_Ultimate_Parent_18_Id_F__c);
                      accid_ultimateParent_id.put(act.id,act.SMB_ACC_Ultimate_Parent_18_Id_F__c);// map of account id and account.Ultimate_Parent_18_Id_F
                    }
                system.debug('acc_ulimateparentids'+acc_ulimateparentids);
                
                list<Account> All_account_associated_to_ultimateaccount=[select id,SMB_ACC_Ultimate_Parent_18_Id_F__c,Ownerid from account where SMB_ACC_Ultimate_Parent_18_Id_F__c In:acc_ulimateparentids];
                system.debug('All_account_associated_to_ultimateaccount'+All_account_associated_to_ultimateaccount.size());
                    for(Account acut : All_account_associated_to_ultimateaccount)
                    {
                        All_account_id.add(acut.id); // set of all account id 
                        // map of Ultimate_Parent and list of account associated to it 
                        if(acc_ultimate .containsKey(acut.SMB_ACC_Ultimate_Parent_18_Id_F__c ))
                        {
                            list<Account> acc=acc_ultimate .get(acut.SMB_ACC_Ultimate_Parent_18_Id_F__c);
                            acc.add(acut);
                            acc_ultimate.put(acut.SMB_ACC_Ultimate_Parent_18_Id_F__c, acc);
                        }
                        else
                        {
                           acc_ultimate.put(acut.SMB_ACC_Ultimate_Parent_18_Id_F__c,new List<Account>{acut});
                        }
                    }  
        
        
          
                list<AccountTeamMember> acc_team_member=[select ID, Account.SMB_ACC_Ultimate_Parent_18_Id_F__c,Accountid,UserId,User.IsActive,AccountAccessLevel,TeamMemberRole from AccountTeamMember where accountId In : All_account_id and User.IsActive=true];
                system.debug('acc_team_member'+acc_team_member.size());
                system.debug('acc_ultimate'+acc_ultimate.size());
                    if(acc_team_member.size()>0)
                    {
                                    for(AccountTeamMember att : acc_team_member)
                                    {   
                                        //map to of ultimate acccount id and list of team member
                                        if(acc_with_map.containsKey(att.Account.SMB_ACC_Ultimate_Parent_18_Id_F__c))
                                        {
                                            List<AccountTeamMember> accTeammember=acc_with_map.get(att.Account.SMB_ACC_Ultimate_Parent_18_Id_F__c);
                                            accTeammember.add(att);
                                            acc_with_map.put(att.Account.SMB_ACC_Ultimate_Parent_18_Id_F__c, accTeammember);
                                        }
                                        else
                                        {
                                            acc_with_map.put(att.Account.SMB_ACC_Ultimate_Parent_18_Id_F__c,new List<AccountTeamMember>{att});
                                        }
                                    } 
                            system.debug('acc_with_map'+acc_with_map.size()); 
                            List<Action_Plan__share> ListOfActionPlanShareOwner=[Select ParentId,RowCause,UserOrGroupId,AccessLevel from Action_Plan__share where ParentId IN:ids and RowCause='Owner'];
                            if(ListOfActionPlanShareOwner.size()>0)
                            {
                                for(Action_Plan__share Aps:ListOfActionPlanShareOwner)
                                {
                                   actionPlanShareMap.put(Aps.UserOrGroupId,Aps.ParentId);
                                }
                              
                            }
                            System.debug('actionPlanShareMap'+actionPlanShareMap);
                            for(Action_Plan__c ap: Ac)  
                            {
                             system.debug('acc_with_map.get(accid_ultimateParent_id.get(ap.SMB_AP_Account__c))'+acc_with_map.get(accid_ultimateParent_id.get(ap.SMB_AP_Account__c)));
                             //system.debug('acc_with_map.get(accid_ultimateParent_id.get(ap.SMB_AP_Account__c))'+acc_with_map.get(accid_ultimateParent_id.get(ap.SMB_AP_Account__c)).size());
                                if(accid_ultimateParent_id.get(ap.SMB_AP_Account__c)!=null && acc_with_map.get(accid_ultimateParent_id.get(ap.SMB_AP_Account__c))!=null )
                                {
                                //Accid_ultimateParent_id will return ultimate parentid and acc_with_map will return list of team member
                                   for(AccountTeamMember Atm : acc_with_map.get(accid_ultimateParent_id.get(ap.SMB_AP_Account__c)))
                                   {     
                                        if(actionPlanShareMap.get(Atm.UserId)!=ap.id)
                                        {
                                             Action_Plan__share actionshar =new Action_Plan__share();
                                             actionshar.ParentId=ap.id;
                                             actionshar.UserOrGroupId=Atm.UserId;
                                             actionshar.AccessLevel = 'Edit';
                                             actionshar.RowCause = Schema.Action_Plan__share.RowCause.Manual;
                                            
                                             Actionplanshare.add(actionshar); 
                                        }
                              
                                   }       
                               }
                            } 
                            
                            // assign action plan share to hierarchy account's owner 
                            for(Action_Plan__c aplan: Ac)  
                            { 
                              if(acc_ultimate.get(accid_ultimateParent_id.get(aplan.SMB_AP_Account__c))!=null){
                                  for(Account accunt: acc_ultimate.get(accid_ultimateParent_id.get(aplan.SMB_AP_Account__c)))
                                   {
                                        if(actionPlanShareMap.get(accunt.ownerid)!=aplan.id)
                                        {
                                          Action_Plan__share actionshar =new Action_Plan__share();
                                          actionshar.ParentId=aplan.id;
                                          actionshar.UserOrGroupId=accunt.OwnerId;
                                          actionshar.AccessLevel = 'Edit';
                                          actionshar.RowCause = Schema.Action_Plan__share.RowCause.Manual;
                                        
                                          ownershare.add(actionshar); 
                               
                                        
                                        }
                                  
                                   }
                                }
                            }
                            if(ownershare.size()>0){
                                Actionplanshare.addAll(ownershare);
                                system.debug('Actionplanshare'+Actionplanshare.size());
                                system.debug('ownershare'+ownershare);
                             }   
                            
                         //   insert Actionplanshare;
                            if(Actionplanshare.size()>0)
                            {
                                        Database.SaveResult[] srlist = Database.insert(Actionplanshare,false); 
                                        
                                        string Error;
                                        for(Database.SaveResult sr : srlist) 
                                        {
                                            if (sr.isSuccess())
                                            {
                                                // Operation was successful, so get the ID of the record that was processed
                                                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                                            }
                                            else {
                                                // Operation failed, so get all errors
                                                 error=sr.getId();               
                                                  for(Database.Error err : sr.getErrors())
                                                   {
                                                        System.debug('The following error has occurred.');                    
                                                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                                        System.debug('Account fields that affected this error: ' + err.getFields());
                                                        Error+=err.getMessage();+err.getFields();+err.getStatusCode();  
                                     
                                                   }
                                                     Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
                                                     String[] toAddresses = new String[] {System.Label.SMB_Action_Batch_Error};
                                                     mail.setToAddresses(toAddresses);
                                                   //  mail.setReplyTo(System.Label.SMB_Action_Batch_Error);
                                                     mail.setSenderDisplayName('Apex error message Action share batch');
                                                     mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
                                                     mail.setPlainTextBody(Error);
                                                     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                                                }
                                        }
                            } 
                    }
      
    }

}