public with sharing class SMBW3_Edit_Opportunity_Split_VPC {
    
        Public list<OpportunitySplit> osCommision{get;set;}
        Public list<OpportunitySplit> osFinance{get;set;}
        Public list<OpportunitySplit> osFinanceUpdate;
        Public list<OpportunitySplit> osCommisionUpdate;
        public list<oppsplitwrapper> osCommisionwrapper{get;set;}
        public list<oppsplitwrapper> osFinancewrapper{get;set;} 
        public list<oppsplitwrapper> wrapperList{get;set;}
        private list<OpportunitySplit> conditionsToBeDeleted ;
        private list<OpportunitySplit> conditionsToBeAdd ;
        private list<OpportunitySplit> conditionsToBeAddnew;
        private list<OpportunitySplit> commisiontofinanace;
        private list<OpportunitySplit> finanacetocommision;
        public integer opport{get;set;}
        public Integer counter{get;set;}  
        public Integer counter1{get;set;}  
        public string ownersid{get;set;}
        public Decimal totalAmount{get;set;}
        public String jsonString {get;set;}
        public String nameofopp{get;set;}
        public Map<string,id> mapuser = new map<string,id>();
        public id ids{get;set;}
        public boolean check=true;
        public boolean check1=true;
        Public string Financesplit;
        Public string commissionsplit;
        Public boolean Errorcheck{get;set;}
        Public Integer deletedcommission=0;
        public boolean checklocale{get;set;}
        Map<string,list<opportunitySplit>> map_A_end_Split = new Map<string,list<opportunitySplit>>();
    
        Public Boolean Profilecheck{get;set;}
        Public Opportunity Oppdata{get;set;}
        public String test{set;get;}
        public  oppsplitwrapper oppslitwrap;
        public string username;

     public SMBW3_Edit_Opportunity_Split_VPC(ApexPages.StandardController controller) {
        system.debug('ss'+userinfo.getLocale()+System.Label.Gam_locale);
        Oppdata=new Opportunity();
        list<string> gamlocales=System.Label.Gam_locale.split(';');
        system.debug('gamlocales'+gamlocales);
        for(string loc:gamlocales){
         if(loc.contains(userinfo.getLocale())){
            checklocale=true;
            system.debug('if'+checklocale);
            break;
         }
         else{
           checklocale=false;
           system.debug('else'+checklocale);
         }
        }
        Id id1 = UserInfo.getProfileId();
        List<String> profiletovisiblefinance=System.Label.Gam_Finance_visible.split(';');
        for(String visible:profiletovisiblefinance){
                if(id1==visible){
                    Profilecheck=true;
                    break;
                }
                else{
                    Profilecheck=false;
                }
       } 
        
        username();
        conditionsToBeDeleted =new list<OpportunitySplit>();
        conditionsToBeAdd =new list<OpportunitySplit>();
        conditionsToBeAddnew =new list<OpportunitySplit>();
        commisiontofinanace=new list<OpportunitySplit>();
        finanacetocommision=new list<OpportunitySplit>();
        ids=ApexPages.CurrentPage().getparameters().get('id');
        Financesplit=Split__c.getValues('Finance').Split_id__c;
        commissionsplit=Split__c.getValues('Commission').Split_id__c;
        
        conditionsToBeDeleted.clear();
        opport=integer.valueOf([SELECT StageName,SMB_OPP_stage_nb__c,SMB_OPP_stage_Gam_nb__c FROM Opportunity where id=:ids].SMB_OPP_stage_Gam_nb__c);
        Oppdata=[SELECT name,ownerid,amount,Finance_split_Cal_method__c FROM Opportunity where id=:ids];
        nameofopp=Oppdata.name;
        ownersid=Oppdata.ownerid;
        osFinance=[select id, OpportunityId,Opportunity.amount,Finance_Amount__c,Finance_Percent__c,A_B_end__c ,Opportunity.id,Split,SplitPercentage,SplitAmount,splitNote,SplitTypeId,SplitOwnerId,SplitOwner.firstname,SplitOwner.lastname,SplitOwner.name from OpportunitySplit where OpportunityId=:ids and SplitTypeId=:Financesplit ORDER BY Opportunity.ownerid ];
  
        // we will add custom setting for this 
        osCommision=[select id,OpportunityId,Split,Commission_Amount__c,CommissionPercent__c,A_B_end__c ,Opportunity.id,SplitPercentage,SplitAmount,splitNote,SplitTypeId,SplitOwnerId,SplitOwner.firstname,SplitOwner.lastname,SplitOwner.name from OpportunitySplit where OpportunityId=:ids and SplitTypeId=:commissionsplit ORDER BY Opportunity.ownerid asc ];
        system.debug('hhhhhhhhhhggggggggggggggggggggggggggg'+osCommision);
        //ownersid= UserInfo.getUserId();
        totalAmount=Oppdata.amount;
        osCommisionwrapper= new list<oppsplitwrapper>();
                counter = 0;
                for(OpportunitySplit oppsp : osCommision){
                    
                     if(oppsp.SplitOwnerId==ownersid){
                       oppsplitwrapper oppWrap = new oppsplitwrapper(oppsp);
                       oppWrap.counterWrap = 0;
                       osCommisionwrapper.add(oppWrap);
                   
                   }
                   else{
                    system.debug('counter'+counter);
                    oppsplitwrapper oppWrap = new oppsplitwrapper(oppsp);  
                     counter++;              
                    oppWrap.counterWrap = counter;
                    osCommisionwrapper.add(oppWrap);
                    
                    
                    }
                    osCommisionwrapper.sort();
                   system.debug('osCommisionwrapper'+osCommisionwrapper); 
                }
                
                osFinancewrapper= new list<oppsplitwrapper>();
                counter1 = 0;
                for(OpportunitySplit oppsp : osFinance){
                    
                      if(oppsp.SplitOwnerId==ownersid){
                       oppsplitwrapper oppWrap = new oppsplitwrapper(oppsp);
                       oppWrap.counterWrap = 0;
                       osFinancewrapper.add(oppWrap);
                   
                   }
                    else{
                    system.debug('counter'+counter);
                    oppsplitwrapper oppWrap = new oppsplitwrapper(oppsp);  
                     counter++;              
                    oppWrap.counterWrap = counter;
                    osFinancewrapper.add(oppWrap);
                    
                    
                    }
                    osFinancewrapper.sort();
                    system.debug('osFinancewrapper'+osFinancewrapper); 
                }

        }

 
    public PageReference Removesplit(list<opportunitysplit> updatewrapper,string splitType){
            list<opportunitysplit> updateoppsplit;
            updateoppsplit= new list<opportunitysplit>();
            list<opportunitysplit> oppsplittodelete;
            oppsplittodelete= new list<opportunitysplit>();
            if(!updatewrapper.isEmpty()){
                for(opportunitysplit splitopp : updatewrapper){
                    updateoppsplit.add(splitopp);
                }
            }
            if(!updateoppsplit.isEmpty()){
                delete updateoppsplit;
            }
        //   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Record Saved Successfully.');
       //    ApexPages.addMessage(myMsg); 
                    if(splitType=='commission')
                    {
                                system.debug('commission');
                                for(opportunitysplit deletefinance:updateoppsplit){
                                    for(oppsplitwrapper financelist:osFinancewrapper){
                                        if(deletefinance.SplitOwnerid==financelist.oppsplit.SplitOwnerid){
                                            oppsplittodelete.add(financelist.oppsplit);
                                            system.debug('hhhhhhhh'+oppsplittodelete);
                                        }
                                    }
                                }
                                try{
                                    delete oppsplittodelete;
                                    system.debug('hhh87878877'+oppsplittodelete);
                            }
                            catch(Exception e){
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Error.');
                                ApexPages.addMessage(myMsg); 
                            }
                    }
                    if(splitType=='finance'){
                            system.debug('Finance');
                            for(opportunitysplit deletecommission:updateoppsplit){
                                    for(oppsplitwrapper commissionlist:osCommisionwrapper){
                                        if(deletecommission.SplitOwnerid==commissionlist.oppsplit.SplitOwnerid){
                                                oppsplittodelete.add(commissionlist.oppsplit);
                                                system.debug('hhhhhffff'+oppsplittodelete);
                                            }
                                    }
                            }
                                try{
                                    delete oppsplittodelete;
                                    system.debug('hhdelte'+oppsplittodelete);
                                }
                                catch(Exception e){
                                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Error.');
                                    ApexPages.addMessage(myMsg); 
                                }
                                    
                        }
            return null;
        }
        
        public void removingRow() {
            
            Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));
            system.debug('---param--'+param);
         //   conditionsToBeDeleted = new List<AP_Task_Condition__c>();
            conditionsToBeDeleted.clear();  
            
            for(Integer i=0;i<osCommisionwrapper.size();i++){
                if(osCommisionwrapper[i].counterWrap == param ){
                   oppsplitwrapper deleteCondition =  osCommisionwrapper.remove(i);
                    system.debug('----MMMMM---'+deleteCondition);
                     if(deleteCondition.oppsplit.SplitOwnerId!=null)
                     { 
                        conditionsToBeDeleted.add(deleteCondition.oppsplit);   
                         system.debug('----MM333333M---'+conditionsToBeDeleted+'00000000000000'+conditionsToBeDeleted.size());
                       //  Removesplit(conditionsToBeDeleted,'commission');
                     }
                }
            }
                   
            counter--;
        }
        
         public void removingRowFinanace() {
            
            Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));
            system.debug('---param--'+param);
         //   conditionsToBeDeleted = new List<AP_Task_Condition__c>();
            
            for(Integer i=0;i<osFinancewrapper.size();i++){
                if(osFinancewrapper[i].counterWrap == param ){
                   oppsplitwrapper deleteCondition =  osFinancewrapper.remove(i);
                    system.debug('----MMMMM---'+deleteCondition);
                     if(deleteCondition.oppsplit.SplitOwnerId!=null)
                     { 
                        conditionsToBeDeleted.clear(); 
                        conditionsToBeDeleted.add(deleteCondition.oppsplit);   
                         system.debug('----MM333333M---'+conditionsToBeDeleted+'00000000000000'+conditionsToBeDeleted.size());
                      //   Removesplit(conditionsToBeDeleted,'finance');
                     }
                }
            }
                   
            counter1--;
        }
        

        public void addRow() {
        
            oppslitwrap= new oppsplitwrapper (new opportunitysplit()); 
           // oppslitwrap.oppsplit.Opportunity.id=ApexPages.CurrentPage().getparameters().get('id');
                    //    oppslitwrap.oppsplit.SplitTypeId='149E0000000CiifIAC';
                    //    oppslitwrap.oppsplit.SplitOwner.Id='005E0000006Oo8s';
                     //  oppslitwrap.oppsplit.customAmount__c=oppsplitcomm.Amount;
            counter++;
            oppslitwrap.counterWrap = counter; 
            system.debug('oppslitwrap'+oppslitwrap); 
            osCommisionwrapper.add(oppslitwrap);
            system.debug('osCommisionwrapper'+osCommisionwrapper); 
            
            
            
          //  return null;
        }
    public void savecommission(){  // try with pagereference 
            Integer percentage=0;
            check=true;
            commisiontofinanace.clear();
            conditionsToBeAddnew.clear();
            conditionsToBeAdd.clear();
            set<string> compare_team_member=new set<string>();
            opportunitysplit finsplit= new opportunitysplit();
            system.debug('oscommission check'+osCommisionwrapper);
        for(oppsplitwrapper commwrap : osCommisionwrapper){
              //  commwrap.oppsplit.SplitPercentage=0.00;
                if(commwrap.oppsplit.id!=null){
                    compare_team_member.add(commwrap.splitmember);
                }
                    
                system.debug('compare_team_member'+compare_team_member);
                if((commwrap.oppsplit.id==null))
                {
                 system.debug('commwrap.splitmember'+commwrap.splitmember);
                 system.debug('contain'+compare_team_member.contains(commwrap.splitmember));
                       if(compare_team_member.contains(commwrap.splitmember)){
                       //   pagereference p = apexpages.Currentpage();
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.Gam_Duplicate_Team_Member);
                            apexpages.addmessage(myMsg);
                            check=false;
                            Errorcheck=false;
                            break;
                          // return null;
                        }
                if(mapuser.get(commwrap.splitmember)!=null){
                    commwrap.oppsplit.SplitOwnerid=mapuser.get(commwrap.splitmember);
                } 
                else{
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.Gam_Team_member_should_be_sales_user_samba);
                       apexpages.addmessage(myMsg);
                       check=false;
                       Errorcheck=false;
                       break;
                } 
             // commwrap.oppsplit.SplitOwnerid=mapuser.get(commwrap.splitmember);
                commwrap.oppsplit.OpportunityId=ApexPages.CurrentPage().getparameters().get('id');
                commwrap.oppsplit.SplitTypeId=Split__c.getValues('Commission').Split_id__c;
             // commwrap.oppsplit.SplitPercentage=00.00;
                commwrap.oppsplit.SplitPercentage=commwrap.oppsplit.CommissionPercent__c;
               
                conditionsToBeAddnew.add(commwrap.oppsplit);
                for(opportunitysplit ops:  conditionsToBeAddnew){
                   if(ops.CommissionPercent__c==null){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please enter Percentage');
                        apexpages.addmessage(myMsg);
                        check=false;
                        Errorcheck=false;
                        break;
                    }
                }
               system.debug('notid'+conditionsToBeAddnew);
              
            }
            else{
                  system.debug('deletedcommission'+deletedcommission); 
                  if(integer.valueOf(commwrap.oppsplit.CommissionPercent__c)!=null){
                  percentage+=integer.valueOf(commwrap.oppsplit.CommissionPercent__c) + deletedcommission; 
                  }
                 commwrap.oppsplit.SplitPercentage=commwrap.oppsplit.CommissionPercent__c;
                  conditionsToBeAdd.add(commwrap.oppsplit);
                   system.debug('withid'+conditionsToBeAdd);
                   system.debug('percentage'+ percentage);
            }
           
        }    
        if(conditionsToBeDeleted.size() > 0){
                if(conditionsToBeDeleted[0].CommissionPercent__c==null){
                    conditionsToBeDeleted[0].CommissionPercent__c=0.00;
                }
        }
        if(conditionsToBeDeleted.size() > 0 && (percentage >= 100 )) {
               Removesplit(conditionsToBeDeleted,'commission');
        }
        if(conditionsToBeDeleted.size() > 0 && (percentage < 100 )){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Update Split Before delete ,Total Percentage should be 100');
                    apexpages.addmessage(myMsg);
                    check=false;
                    deletedcommission=integer.valueOf(conditionsToBeDeleted[0].CommissionPercent__c); 
                    system.debug('deletedcommission'+deletedcommission);
                    
                    Errorcheck=false;
                   // break;
                    
        }
           
        try
           {
           if(conditionsToBeAdd.size()>0){
           conditionsToBeAdd.addAll(conditionsToBeAddnew);
           createA_end_Map();       
           for(opportunitysplit ops :conditionsToBeAddnew){
               opportunitysplit commissionadd=new opportunitysplit();
               commissionadd.SplitTypeId=Split__c.getValues('Finance').Split_id__c;
               commissionadd.Finance_Percent__c=ops.CommissionPercent__c;
               commissionadd.A_B_end__c=ops.A_B_end__c;
               commissionadd.Finance_Amount__c=ops.Commission_Amount__c;
               commissionadd.SplitPercentage=commissionadd.Finance_Percent__c;
       /*        if(ops.A_B_end__c=='B end'){
                        commissionadd.Finance_Percent__c=(ops.CommissionPercent__c)/2;
                        commissionadd.A_B_end__c=ops.A_B_end__c;
                        commissionadd.Finance_Amount__c=ops.Commission_Amount__c*((ops.CommissionPercent__c)/2);
               }
               
              else if(ops.A_B_end__c=='A  end' && map_A_end_Split.get('A end').size()>0){  
                       commissionadd.Finance_Percent__c=0.00;
                       // commissionadd.A_B_end__c=ops.A_B_end__c;
                        commissionadd.Finance_Amount__c=0.00; 
                    }
             else if(ops.A_B_end__c=='A  end' && map_A_end_Split.get('A end').size()==0){  
                       commissionadd.Finance_Percent__c=100;
                       // commissionadd.A_B_end__c=ops.A_B_end__c;
                        commissionadd.Finance_Amount__c=ops.Commission_Amount__c;
                    }       
             else if(ops.A_B_end__c=='Russia (i)'){
                        commissionadd.Finance_Percent__c=100;
                        commissionadd.A_B_end__c=ops.A_B_end__c;
                        commissionadd.Finance_Amount__c=ops.Commission_Amount__c;
                    }
             else if(ops.A_B_end__c=='Russia (o)'){
                        commissionadd.Finance_Percent__c=0;
                        commissionadd.A_B_end__c=ops.A_B_end__c;
                        commissionadd.Finance_Amount__c=0;
                    }       
             else if(ops.A_B_end__c=='BM/BP (DGC)'){
                        commissionadd.Finance_Percent__c=0;
                        commissionadd.A_B_end__c=ops.A_B_end__c;
                        commissionadd.Finance_Amount__c=0;
                    }           
                
             */  
               commissionadd.SplitOwnerid=ops.SplitOwnerid;
               commissionadd.OpportunityId=ops.OpportunityId;
             //  ops.SplitAmount=00.00;
               commissionadd.SplitNote='';
               
               commisiontofinanace.add(commissionadd);
               system.debug('fffufffufff'+commisiontofinanace);
               
           }
           if(check){
               Errorcheck=true;
               upsert conditionsToBeAdd;
               insert commisiontofinanace;
               upadteFinancesplit();
           }
         }
          
        }
           catch(Exception e)
           {
            ApexPages.addMessages(e) ; 
           }
          
        //  return null;
        //  return (new PageReference ('/apex/SMBW3_Edit_Opportunity_Split_VPC?id='+ApexPages.CurrentPage().getparameters().get('id')));
        }
            public void createA_end_Map(){
                osFinanceupdate=[select id, OpportunityId,Opportunity.amount,Finance_Amount__c,Finance_Percent__c,A_B_end__c ,Opportunity.id,Split,SplitPercentage,SplitAmount,splitNote,SplitTypeId,SplitOwner.Id,SplitOwner.firstname,SplitOwner.lastname,SplitOwner.name from OpportunitySplit where OpportunityId=:ids and SplitTypeId=:Financesplit ORDER BY Opportunity.ownerid ];
                for(opportunitysplit financesplit:osFinanceupdate){
                            if(financesplit.A_B_end__c=='A end'){
                                
                                    if(map_A_end_Split.containsKey(financesplit.A_B_end__c)){
                                        List<Opportunitysplit> splits = map_A_end_Split.get(financesplit.A_B_end__c);
                                         splits.add(financesplit);
                                         map_A_end_Split.put(financesplit.A_B_end__c,splits);
                            
                                         }
                                      else{
                                              map_A_end_Split.put(financesplit.A_B_end__c,new List<Opportunitysplit> {financesplit});
                                      
                                        }  
                                    
                            }
            }       
             system.debug('map_A_end_Split'+map_A_end_Split);
            }
            public void upadteFinancesplit(){
                
                Map<string,list<opportunitySplit>> map_B_end_Split = new Map<string,list<opportunitySplit>>();
                Map<id,opportunitySplit> map_B_commission_end_Split_withTeammember = new Map<id,opportunitySplit>();
                Map<id,opportunitySplit> map_A_commission_end_Split_withTeammember = new Map<id,opportunitySplit>();
                Map<id,opportunitySplit> map_Russia_o_commission_end_Split_withTeammember = new Map<id,opportunitySplit>();
                Map<id,opportunitySplit> map_Russia_i_commission_end_Split_withTeammember = new Map<id,opportunitySplit>();
                Map<id,opportunitySplit> map_Russia_BM_BP_commission_end_Split_withTeammember = new Map<id,opportunitySplit>();
                Map<id,opportunitySplit> map_B_Finance_end_Split_withTeammember = new Map<id,opportunitySplit>();
                Map<id,opportunitySplit> map_A_Finance_end_Split_withTeammember = new Map<id,opportunitySplit>();
                list<OpportunitySplit> B_end_Finance= new list<OpportunitySplit>();
                list<OpportunitySplit> A_end_Finance= new list<OpportunitySplit>();
                
                Decimal SumOf_B_end=0.00;
                        osFinanceupdate=[select id, OpportunityId,Opportunity.amount,Finance_Amount__c,Finance_Percent__c,A_B_end__c,Opportunity.ownerid ,Opportunity.id,Split,SplitPercentage,SplitAmount,splitNote,SplitTypeId,SplitOwner.Id,SplitOwner.firstname,SplitOwner.lastname,SplitOwner.name from OpportunitySplit where OpportunityId=:ids and SplitTypeId=:Financesplit ORDER BY Opportunity.ownerid DESC];
                    
                osCommisionupdate=[select id,OpportunityId,Split,Commission_Amount__c,CommissionPercent__c,A_B_end__c,Opportunity.ownerid ,Opportunity.id,SplitPercentage,SplitAmount,splitNote,SplitTypeId,SplitOwner.Id,SplitOwner.firstname,SplitOwner.lastname,SplitOwner.name from OpportunitySplit where OpportunityId=:ids and SplitTypeId=:commissionsplit ORDER BY Opportunity.ownerid DESC ];
                system.debug('osCommisionupdate'+osCommisionupdate.size());
                    for(opportunitysplit commissionsplit:osCommisionupdate){
                      system.debug('commissionsplit.A_B_end__c'+commissionsplit.A_B_end__c);
                        if(commissionsplit.A_B_end__c=='B end'){
                             
                                 map_B_commission_end_Split_withTeammember.put(commissionsplit.SplitOwner.id,commissionsplit);
                            
                                        
                        
                        }
                        if(commissionsplit.A_B_end__c=='A end'){
                            system.debug('testA'+commissionsplit.A_B_end__c);
                            map_A_commission_end_Split_withTeammember.put(commissionsplit.SplitOwner.id,commissionsplit);
                        
                        }
                        if(commissionsplit.A_B_end__c=='Russia (i)'){
                            map_Russia_i_commission_end_Split_withTeammember.put(commissionsplit.SplitOwner.id,commissionsplit);
                        
                        }
                        if(commissionsplit.A_B_end__c=='Russia (o)'){
                            map_Russia_o_commission_end_Split_withTeammember.put(commissionsplit.SplitOwner.id,commissionsplit);
                        
                        }
                        if(commissionsplit.A_B_end__c=='BM/BP (DGC)'){
                            map_Russia_BM_BP_commission_end_Split_withTeammember.put(commissionsplit.SplitOwner.id,commissionsplit);
                        
                        }
                    }
                    system.debug('osCommisionupdate1'+osCommisionupdate);
                    system.debug('map_B_commission_end_Split_withTeammember'+map_B_commission_end_Split_withTeammember.size());
                    system.debug('map_A_commission_end_Split_withTeammember'+map_A_commission_end_Split_withTeammember);
                    system.debug('map_Russia_i_commission_end_Split_withTeammember'+map_Russia_i_commission_end_Split_withTeammember.size());
                    system.debug('map_Russia_o_commission_end_Split_withTeammember'+map_Russia_o_commission_end_Split_withTeammember.size());
                    system.debug('map_Russia_BM_BP_commission_end_Split_withTeammember'+map_Russia_BM_BP_commission_end_Split_withTeammember.size());
                    for(opportunitysplit financesplit:osFinanceupdate){
                      //  if(financesplit.A_B_end__c=='B end')
                        {
                             
                                 map_B_Finance_end_Split_withTeammember.put(financesplit.SplitOwner.id,financesplit);
                    
                        }
                    /*  if(financesplit.A_B_end__c=='A end'){
                            map_A_Finance_end_Split_withTeammember.put(financesplit.SplitOwner.id,financesplit);
                        
                        } 
                    */  
                    }
                    system.debug('map_B_Finance_end_Split_withTeammember'+map_B_Finance_end_Split_withTeammember.size());
                    system.debug('map_A_Finance_end_Split_withTeammember'+map_A_Finance_end_Split_withTeammember.size());
                
                //----------------------------------having russia 0-------------------------------------------  

                opportunitySplit finsplit= new opportunitySplit();
                if(map_Russia_o_commission_end_Split_withTeammember.size()>0 && map_A_commission_end_Split_withTeammember.size()==0 && map_B_commission_end_Split_withTeammember.size()>0){
                     system.debug('1');
                        for(opportunitysplit commisssplit : map_Russia_o_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0;
                                finsplit.Finance_Amount__c=0;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;  
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;
                                    
                                B_end_Finance.add(finsplit); 
                        }
                        
                        for(opportunitysplit commisssplit : map_B_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=commisssplit.CommissionPercent__c;
                                finsplit.Finance_Amount__c=commisssplit.Commission_Amount__c;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;                               
                                B_end_Finance.add(finsplit);
                                SumOf_B_end+=finsplit.Finance_Percent__c;
                        
                        }
                
                }
                // having russia o and with A-end also 
            else if(map_Russia_o_commission_end_Split_withTeammember.size()>0 && map_A_commission_end_Split_withTeammember.size()>0 && map_B_commission_end_Split_withTeammember.size()>0){
                     system.debug('2');
                        for(opportunitysplit commisssplit : map_Russia_o_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0;
                                finsplit.Finance_Amount__c=0;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;       
                                    system.debug('finsplit.A_B_end__c with A split'+ finsplit.A_B_end__c);
                                B_end_Finance.add(finsplit); 
                        }
                        
                        for(opportunitysplit commisssplit : map_B_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=commisssplit.CommissionPercent__c/2;
                                finsplit.Finance_Amount__c=commisssplit.Commission_Amount__c/2;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c; 
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                B_end_Finance.add(finsplit);
                                SumOf_B_end+=finsplit.Finance_Percent__c;
                        
                        }
                        if(map_A_commission_end_Split_withTeammember.size()==1){    
                        for(opportunitysplit commisssplit : map_A_commission_end_Split_withTeammember.values()){
                             //   opportunitysplit finnancesplit=new opportunitysplit();
                             
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=100.00-SumOf_B_end;
                                finsplit.Finance_Amount__c=(finsplit.Opportunity.amount*(100-SumOf_B_end))/100; 
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;
                                B_end_Finance.add(finsplit);
                                
                            }
                                    
                        
                    }
                    else{
                            system.debug('map_A_commission_end_Split_withTeammember.values()'+map_A_commission_end_Split_withTeammember.values()); 
                            list<opportunitysplit>commissionsplitlist=map_A_commission_end_Split_withTeammember.values();
                            commissionsplitlist.sort();
                            system.debug('map_B_Finance_end_Split_withTeammember.get(commissionsplitlist[0]'+map_B_Finance_end_Split_withTeammember.get(commissionsplitlist[0].SplitOwner.id));
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commissionsplitlist[0].SplitOwner.id);
                                finsplit.Finance_Percent__c=100.00-SumOf_B_end;
                                finsplit.Finance_Amount__c=(finsplit.Opportunity.amount*(100-SumOf_B_end))/100; 
                                finsplit.A_B_end__c=commissionsplitlist[0].A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;
                                B_end_Finance.add(finsplit);
                                commissionsplitlist.remove(0);  
                                system.debug('commissionsplitlist'+commissionsplitlist);
                            for(opportunitysplit commisssplit : commissionsplitlist){
                             //   opportunitysplit finnancesplit=new opportunitysplit();
                             
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0;
                                finsplit.Finance_Amount__c=0; 
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;
                                B_end_Finance.add(finsplit);
                                
                            }
                                
                    
                        }
                
                
                }
             else if(map_Russia_o_commission_end_Split_withTeammember.size()>0 && map_A_commission_end_Split_withTeammember.size()==0 && map_B_commission_end_Split_withTeammember.size()==0){
                     system.debug('2');
                        for(opportunitysplit commisssplit : map_Russia_o_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0;
                                finsplit.Finance_Amount__c=0;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                    system.debug('finsplit.A_B_end__c with A split'+ finsplit.A_B_end__c);
                                B_end_Finance.add(finsplit); 
                        }
                        
                        
                
                }
                else if(map_Russia_o_commission_end_Split_withTeammember.size()>0 && map_A_commission_end_Split_withTeammember.size()>0 && map_B_commission_end_Split_withTeammember.size()==0){
                     system.debug('one a ned and rus i');
                        for(opportunitysplit commisssplit : map_Russia_o_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0;
                                finsplit.Finance_Amount__c=0;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                    system.debug('finsplit.A_B_end__c with A split'+ finsplit.A_B_end__c);
                                B_end_Finance.add(finsplit); 
                        }
                        
                        
                
                }
                // -------------------------having Russia i ------------------------------------------- 
                else if(map_Russia_i_commission_end_Split_withTeammember.size()>0 && map_B_commission_end_Split_withTeammember.size()>0 && map_A_commission_end_Split_withTeammember.size()>0 ){
                system.debug('3');
                    for(opportunitysplit commisssplit : map_Russia_i_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=100;
                                finsplit.Finance_Amount__c=finsplit.Opportunity.amount;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                    system.debug('finsplit.A_B_i_end__c with A split'+ finsplit.A_B_end__c);
                                B_end_Finance.add(finsplit); 
                    }
                
                    for(opportunitysplit commisssplit : map_B_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0;
                                finsplit.Finance_Amount__c=0;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                B_end_Finance.add(finsplit);
                                
                        
                        }
                        for(opportunitysplit commisssplit : map_A_commission_end_Split_withTeammember.values()){
                               // opportunitysplit finnancesplit=new opportunitysplit();
                              
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0;
                                finsplit.Finance_Amount__c=0;   
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;
                                B_end_Finance.add(finsplit);
                        
                        
                        }   
                
                
                }
                              // -------------------------having Russia i ------------------------------------------- 
                else if(map_Russia_i_commission_end_Split_withTeammember.size()>0 && map_B_commission_end_Split_withTeammember.size()>0 && map_A_commission_end_Split_withTeammember.size()==0 ){
                system.debug('3');
                    for(opportunitysplit commisssplit : map_Russia_i_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=100;
                                finsplit.Finance_Amount__c=finsplit.Opportunity.amount;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                    system.debug('finsplit.A_B_i_end__c with A split'+ finsplit.A_B_end__c);
                                B_end_Finance.add(finsplit); 
                    }
                
                    for(opportunitysplit commisssplit : map_B_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0;
                                finsplit.Finance_Amount__c=0;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                B_end_Finance.add(finsplit);
                                
                        
                        }
                         
                
                
                }
                //---------------------------russia------------i-------------------------------
            else if(map_Russia_i_commission_end_Split_withTeammember.size()>0 && map_B_commission_end_Split_withTeammember.size()>0 && map_A_commission_end_Split_withTeammember.size()==0 ){
                system.debug('3');
                    for(opportunitysplit commisssplit : map_Russia_i_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=100;
                                finsplit.Finance_Amount__c=finsplit.Opportunity.amount;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                    system.debug('finsplit.A_B_i_end__c with A split'+ finsplit.A_B_end__c);
                                B_end_Finance.add(finsplit); 
                    }
                
                    for(opportunitysplit commisssplit : map_B_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0;
                                finsplit.Finance_Amount__c=0;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;                            
                                B_end_Finance.add(finsplit);
                                
                        
                        }
                         
                
                
                }
                    //---------------------------russia(i)-------------------------------
            else if(map_Russia_i_commission_end_Split_withTeammember.size()>0 && map_B_commission_end_Split_withTeammember.size()==0 && map_A_commission_end_Split_withTeammember.size()>0 ){
                system.debug('3');
                    for(opportunitysplit commisssplit : map_Russia_i_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=100;
                                finsplit.Finance_Amount__c=finsplit.Opportunity.amount;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                    system.debug('finsplit.A_B_i_end__c with A split'+ finsplit.A_B_end__c);
                                B_end_Finance.add(finsplit); 
                    }
                
                    for(opportunitysplit commisssplit : map_A_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0;
                                finsplit.Finance_Amount__c=0;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                B_end_Finance.add(finsplit);
                                
                        
                        }
                         
                
                
                }
                              // -------------------------having Russia i ------------------------------------------- 
                else if(map_Russia_i_commission_end_Split_withTeammember.size()>0 && map_B_commission_end_Split_withTeammember.size()==0 &&     map_A_commission_end_Split_withTeammember.size()==0 ){
                system.debug('3');
                    for(opportunitysplit commisssplit : map_Russia_i_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=100;
                                finsplit.Finance_Amount__c=finsplit.Opportunity.amount;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                    system.debug('finsplit.A_B_i_end__c with A split'+ finsplit.A_B_end__c);
                                B_end_Finance.add(finsplit); 
                    }
                
                   
                
                
                }
                else if(map_Russia_BM_BP_commission_end_Split_withTeammember.size()>0 && map_B_commission_end_Split_withTeammember.size()>0 && map_A_commission_end_Split_withTeammember.size()>0){
                system.debug('B_end_Finance'+B_end_Finance);
                system.debug('4');
                     for(opportunitysplit commisssplit : map_Russia_BM_BP_commission_end_Split_withTeammember.values()) {
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0;
                                finsplit.Finance_Amount__c=0;   
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                B_end_Finance.add(finsplit);
                     
                     }
                     for(opportunitysplit commisssplit : map_B_commission_end_Split_withTeammember.values()){
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=commisssplit.CommissionPercent__c/2;
                                finsplit.Finance_Amount__c=commisssplit.Commission_Amount__c/2;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                B_end_Finance.add(finsplit);
                                SumOf_B_end+=finsplit.Finance_Percent__c;
                        
                        }
                    if(map_A_commission_end_Split_withTeammember.size()==1){    
                        for(opportunitysplit commisssplit : map_A_commission_end_Split_withTeammember.values()){
                             //   opportunitysplit finnancesplit=new opportunitysplit();
                             
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=100.00-SumOf_B_end;
                                finsplit.Finance_Amount__c=(finsplit.Opportunity.amount*(100-SumOf_B_end))/100; 
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                B_end_Finance.add(finsplit);
                                
                            }
                                    
                        
                    }
                    else{
                            system.debug('map_A_commission_end_Split_withTeammember.values()'+map_A_commission_end_Split_withTeammember.values()); 
                            list<opportunitysplit>commissionsplitlist=map_A_commission_end_Split_withTeammember.values();
                            commissionsplitlist.sort();
                            system.debug('map_B_Finance_end_Split_withTeammember.get(commissionsplitlist[0]'+map_B_Finance_end_Split_withTeammember.get(commissionsplitlist[0].SplitOwner.id));
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commissionsplitlist[0].SplitOwner.id);
                                finsplit.Finance_Percent__c=100.00-SumOf_B_end;
                                finsplit.Finance_Amount__c=(finsplit.Opportunity.amount*(100-SumOf_B_end))/100; 
                                finsplit.A_B_end__c=commissionsplitlist[0].A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;
                                B_end_Finance.add(finsplit);
                                commissionsplitlist.remove(0);  
                                system.debug('commissionsplitlist'+commissionsplitlist);
                            for(opportunitysplit commisssplit : commissionsplitlist){
                             //   opportunitysplit finnancesplit=new opportunitysplit();
                             
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0;
                                finsplit.Finance_Amount__c=0; 
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;
                                B_end_Finance.add(finsplit);
                                
                            }
                                
                    
                        }
                
                
                
                }
                else if(map_Russia_BM_BP_commission_end_Split_withTeammember.size()>0 && map_A_commission_end_Split_withTeammember.size()>0 && map_B_commission_end_Split_withTeammember.size()==0){
                system.debug('4');
                     for(opportunitysplit commisssplit : map_Russia_BM_BP_commission_end_Split_withTeammember.values()) {
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0.00;
                                finsplit.Finance_Amount__c=0;   
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;
                                B_end_Finance.add(finsplit);
                     
                     }
                    
                        for(opportunitysplit commisssplit : map_A_commission_end_Split_withTeammember.values()){
                             //   opportunitysplit finnancesplit=new opportunitysplit();
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=commisssplit.CommissionPercent__c;
                                finsplit.Finance_Amount__c=commisssplit.Commission_Amount__c;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;
                                B_end_Finance.add(finsplit);
                        
                        
                        }
                
                
                
                }
                else if(map_Russia_BM_BP_commission_end_Split_withTeammember.size()>0 && map_A_commission_end_Split_withTeammember.size()==0 && map_B_commission_end_Split_withTeammember.size()>0){
                system.debug('4');
                     for(opportunitysplit commisssplit : map_Russia_BM_BP_commission_end_Split_withTeammember.values()) {
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0;
                                finsplit.Finance_Amount__c=0;   
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;
                                B_end_Finance.add(finsplit);
                     
                     }
                    
                        for(opportunitysplit commisssplit : map_B_commission_end_Split_withTeammember.values()){
                             //   opportunitysplit finnancesplit=new opportunitysplit();
                             
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=commisssplit.CommissionPercent__c/2;
                                finsplit.Finance_Amount__c=commisssplit.Commission_Amount__c/2;
                                finsplit.A_B_end__c=commisssplit.A_B_end__c; 
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;                               
                                B_end_Finance.add(finsplit);
                                SumOf_B_end+=finsplit.Finance_Percent__c;
                        
                        
                        }
                
                
                
                }
                else if(map_Russia_BM_BP_commission_end_Split_withTeammember.size()>0 && map_A_commission_end_Split_withTeammember.size()==0 && map_B_commission_end_Split_withTeammember.size()==0){
                system.debug('4');
                     for(opportunitysplit commisssplit : map_Russia_BM_BP_commission_end_Split_withTeammember.values()) {
                                finsplit=map_B_Finance_end_Split_withTeammember.get(commisssplit.SplitOwner.id);
                                finsplit.Finance_Percent__c=0;
                                finsplit.Finance_Amount__c=0;   
                                finsplit.A_B_end__c=commisssplit.A_B_end__c;
                                finsplit.SplitPercentage=finsplit.Finance_Percent__c;
                                B_end_Finance.add(finsplit);
                     
                     }
                    
                                    
                
                
                }
                else{
                system.debug('5');
                        for(opportunitysplit comm:map_B_commission_end_Split_withTeammember.values()){
                            //  opportunitysplit finsplit=new opportunitysplit();
                                finsplit=map_B_Finance_end_Split_withTeammember.get(comm.SplitOwner.id);
                                        finsplit.Finance_Percent__c=comm.CommissionPercent__c/2;
                                        finsplit.Finance_Amount__c=comm.Commission_Amount__c/2;
                                        finsplit.A_B_end__c=comm.A_B_end__c; 
                                        finsplit.SplitPercentage=finsplit.Finance_Percent__c;   
                                        B_end_Finance.add(finsplit);
                                        SumOf_B_end+=finsplit.Finance_Percent__c;
                                        system.debug('SumOf_B_end'+SumOf_B_end);
                                
                                
                                    
                    
                        }
                    //update B_end_Finance;
                    
                    list<opportunitysplit> commissions=map_A_commission_end_Split_withTeammember.values();
                    commissions.sort();
                    system.debug('commissions'+commissions);
                        if(commissions.size()>0){
                                opportunitysplit finnancesplit=new opportunitysplit();
                                finnancesplit=map_B_Finance_end_Split_withTeammember.get(commissions[0].SplitOwner.id);
                                finnancesplit.Finance_Percent__c=100.00-SumOf_B_end;
                                finnancesplit.Finance_Amount__c=(finnancesplit.Opportunity.amount*(100-SumOf_B_end))/100;   
                                finnancesplit.A_B_end__c=commissions[0].A_B_end__c;
                                finnancesplit.SplitPercentage=finnancesplit.Finance_Percent__c;
                                B_end_Finance.add(finnancesplit);
                                map_A_commission_end_Split_withTeammember.remove(commissions[0].SplitOwner.id);
                                
                            }
                                system.debug('map_A_commission_end_Split_withTeammember1'+map_A_commission_end_Split_withTeammember);
                    if(map_A_commission_end_Split_withTeammember.size()>0){
                            for(opportunitysplit commsi:map_A_commission_end_Split_withTeammember.values()){
                                system.debug('map_A_commission_end_Split_withTeammember2'+map_A_commission_end_Split_withTeammember);
                                 opportunitysplit finnancesplt=new opportunitysplit();
                                        finnancesplt=map_B_Finance_end_Split_withTeammember.get(commsi.SplitOwner.id);
                                        finnancesplt.Finance_Percent__c=00.00;
                                        finnancesplt.Finance_Amount__c=00.00;   
                                        finnancesplt.A_B_end__c=commsi.A_B_end__c;
                                        finnancesplt.SplitPercentage=finnancesplt.Finance_Percent__c;
                                        B_end_Finance.add(finnancesplt);
                            
                            
                            }
                    }   
                    system.debug('B_end_Finance'+B_end_Finance);
                
                
                }
                
                
            
                system.debug('B_end_Finance'+B_end_Finance);
            try   { 
               if(B_end_Finance.size()>0 ){
                        update B_end_Finance;
                        if(Oppdata.Finance_split_Cal_method__c=='Manual'){
                           Oppdata.Finance_split_Cal_method__c='Check'; 
                           update Oppdata;
                        }
                        
                    
                    }   
            }
            catch(Exception e){}
        }
            
            
        
          public PageReference saveclosecommission(){
              savecommission();
              return (new PageReference ('/'+ApexPages.CurrentPage().getparameters().get('id')));     
          
          }
        public void addRowFinance() {
        
        oppsplitwrapper oppslitwrap= new oppsplitwrapper (new opportunitysplit()); 
            
            counter1++;
            oppslitwrap.counterWrap = counter1; 
            osFinancewrapper.add(oppslitwrap); 
          //  return null;
        }


    public void saveFinance(){
         Integer percentage=0;
         check1=true;
         set<string> comparefinance_team_member=new set<string>();
            conditionsToBeAddnew.clear();
            finanacetocommision.clear();
            conditionsToBeAdd.clear();
           system.debug('osfinance check'+osFinancewrapper);
           for(oppsplitwrapper finwrap : osFinancewrapper){
               //finwrap.oppsplit.SplitPercentage=0.00;
                if(finwrap.oppsplit.id!=null){
                        comparefinance_team_member.add(finwrap.splitmember);
                    }
                
              If((finwrap.oppsplit.id==null)){
                 system.debug('finwrap.splitmember'+finwrap.splitmember);
                     if(comparefinance_team_member.contains(finwrap.splitmember)){
               //     pagereference p = apexpages.Currentpage();
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.Gam_Duplicate_Team_Member);
                    apexpages.addmessage(myMsg);
                    check1=false;
                    Errorcheck=false;
                    break;
                  // return null;
                    }
                    
                if(mapuser.get(finwrap.splitmember)!=null){
                    finwrap.oppsplit.SplitOwnerid=mapuser.get(finwrap.splitmember);
                } 
                else{
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.Gam_Team_member_should_be_sales_user_samba);
                       apexpages.addmessage(myMsg);
                       check1=false;
                       Errorcheck=false;
                       break;
                }   
                    
                     //  finwrap.oppsplit.SplitOwnerid=mapuser.get(finwrap.splitmember);
                       finwrap.oppsplit.OpportunityId=ApexPages.CurrentPage().getparameters().get('id');
                       finwrap.oppsplit.SplitTypeId=Split__c.getValues('Finance').Split_id__c;
                       finwrap.oppsplit.SplitPercentage=finwrap.oppsplit.Finance_Percent__c;
                       
                       conditionsToBeAddnew.add(finwrap.oppsplit);
                       system.debug('notid'+conditionsToBeAddnew);
                        for(opportunitysplit ops:  conditionsToBeAddnew){
                          If(ops.Finance_Percent__c==null){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please enter Percentage');
                        apexpages.addmessage(myMsg);
                        check1=false;
                        Errorcheck=false;
                        break;
                }
                   
               }
             
              }
               else{
                    system.debug('deletedcommission'+deletedcommission); 
                  if(integer.valueOf(finwrap.oppsplit.Finance_Percent__c)!=null){
                  percentage+=integer.valueOf(finwrap.oppsplit.Finance_Percent__c) + deletedcommission; 
                  }
                  finwrap.oppsplit.SplitPercentage=finwrap.oppsplit.Finance_Percent__c;
                  conditionsToBeAdd.add(finwrap.oppsplit);
                   system.debug('withid'+conditionsToBeAdd);
                   system.debug('percentage'+ percentage);
                    
                    
                  
              }
           
           }
                     if(conditionsToBeDeleted.size() > 0){
                if(conditionsToBeDeleted[0].Finance_Percent__c==null){
                    conditionsToBeDeleted[0].Finance_Percent__c=0.00;
                }
                }
                if(conditionsToBeDeleted.size() > 0 && (percentage- conditionsToBeDeleted[0].Finance_Percent__c >= 100 )) {
               Removesplit(conditionsToBeDeleted,'Finance');
            }
                if(conditionsToBeDeleted.size() > 0 && (percentage- conditionsToBeDeleted[0].Finance_Percent__c < 100 )){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Update Split Before delete ,Total Percentage should be 100');
                    apexpages.addmessage(myMsg);
                    check1=false;
                    deletedcommission=integer.valueOf(conditionsToBeDeleted[0].Finance_Percent__c); 
                    system.debug('deletedcommission'+deletedcommission);
                    
                    Errorcheck=false;
                   // break;
                    
                }
            
            
            
           
           try{
           if(conditionsToBeAdd.size()>0){
                 
           conditionsToBeAdd.addAll(conditionsToBeAddnew);
           
           for(opportunitysplit ops :conditionsToBeAddnew){
               opportunitysplit commissionadd=new opportunitysplit();
               commissionadd.SplitTypeId=Split__c.getValues('Commission').Split_id__c;
               commissionadd.SplitPercentage=00.00;
               commissionadd.SplitOwnerid=ops.SplitOwnerid;
               commissionadd.OpportunityId=ops.OpportunityId;
             //  commissionadd.SplitAmount=00.00;
               commissionadd.SplitNote='';
               
               finanacetocommision.add(commissionadd);
               system.debug('fffufffufff'+commisiontofinanace);
               
           }
           if(check1){
           Errorcheck=true;
           upsert conditionsToBeAdd;
          // FinanceAEnd(); 
           {
               Oppdata.Finance_split_Cal_method__c='Manual'; 
               update Oppdata;
           }             
                        
           
        //   insert finanacetocommision;
           }
           }
           }
           catch(Exception e){
             ApexPages.addMessages(e) ; 
           }
           //return null;
       //    return (new PageReference ('/apex/SMBW3_Edit_Opportunity_Split_VPF?id='+ApexPages.CurrentPage().getparameters().get('id')));
         
        }
        
       
        public PageReference saveclosefinance(){
              saveFinance();
         return (new PageReference ('/'+ApexPages.CurrentPage().getparameters().get('id')));     
          
          }

        public String selectedMovie {get; set;}
        public string  Teammember{get;set;}

        public void  username() {
         //   System.debug('Movie Name is: '+Split__c.getValues('Sales User SAMBA').Split_id__c);
            Map<id,profile> salesProfMap = new map<id,profile>([SELECT Id,Name FROM Profile where name=:System.Label.Sales_User_SAMBA  OR name=:System.Label.Business_Developer_User_SAMBA]);
            Set<id> salesProfIds=salesProfMap.keyset();
            List<user> username= [Select id,Name,profileid,isactive from user where profileid IN : salesProfIds and isActive = true];
            // custom setting for profile id
            
            JSONGenerator generator = JSON.createGenerator(true);   //instantiation of the generator
            generator.writeStartArray();
                          // Writes the starting marker of a JSON object '{'
            for(user u:username){
            mapuser.put(u.name,u.id);
            generator.writeStartObject(); 
            generator.writeStringField('label', u.Name); 
            generator.writeEndObject();
            }
            
            system.debug('222222222222222222222222222222222222222222222'+mapuser.get('Petri Kiili'));
           // generator.writeNumberField('count', contacts.size());   //Writes the # of contacts 
            generator.writeEndArray();
           //   generator.writeEndObject();                 //Writes the ending marker of a JSON object '}'
            jsonString = generator.getAsString();
         //   jsonString =JSON.serialize(username);
               
                }

       

   

        
        public class oppsplitwrapper implements Comparable{
         
             public OpportunitySplit oppsplit{get;set;}
             public Integer counterWrap{get;set;}
             public Decimal Amount{get;set;}
             public string splitmember{get;set;}
              
              public oppsplitwrapper(OpportunitySplit opsplit){
               this.oppsplit=opsplit;
            //   this.Amount=opsplit.customAmount__c;
               if((oppsplit!=null)){
               if(opsplit.SplitOwner.firstname!=null)
               this.splitmember=opsplit.SplitOwner.firstname +' '+ opsplit.SplitOwner.lastname;
               }
              }
              
                public Integer compareTo(Object CompareTo) {
                 //   return counterWrap.CompareTo(((oppsplitwrapper)ObjToCompare).counterWrap);
                    
                    oppsplitwrapper compareToRec = (oppsplitwrapper)CompareTo;
                    Integer returnValue = 0;
                            if (counterWrap > compareToRec.counterWrap) {
                                returnValue=1;
                            } else if (counterWrap < compareToRec.counterWrap ) {
                                returnValue =-1;
                            }
                          return returnValue;  
                            
                }
        }   

    }