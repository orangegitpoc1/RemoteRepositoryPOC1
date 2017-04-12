global class SMB_Permission_Set_Ctrl {
    
    public  PermissionSetAssignment             pPSA        {get;set;}      // contiendra une instance de Permission 
    public  list <PermissionSetAssignment>      listOFPSA   {get;set;}      // liste de permission set
    public  class DecoratedPSA {                                            // un Decorateur contien
        public PermissionSetAssignment pPSA { get;  set; }   
        public integer          psaListIndex {get;set;}
        public String           AssigneeName{get;set;}                          
        public PermissionSet    PermissionSetId {get;set;}                  
        public Boolean          isOwnedByProfile{get;set;}   
        public boolean          selected        {get;set;}
        //constructeur du decorateur
        public DecoratedPSA (PermissionSetAssignment pPSA) {         
            this.pPSA                   = pPSA;  
            this.PermissionSetId        =null;
            this.AssigneeName           = '';
            this.isOwnedByProfile       = false;
            this.psaListIndex           = 0;
            this.selected =false;
        }
        
    }
    public  list<DecoratedPSA>              listPSA {get;set;}
    Public  String                          labelToSearch;
    Public  String                          labelToAdd;
    Public  String                          assigneeToSearch{get;set;}
    Public  List<Integer>                   selectedPSAindex{get;set;}
    public  String                          UserName {get; set;}
    public  Id                              UserId {get; set;}
    public  List<User>                      listUsers {get;set;}
    public String                           message1{get;set;}
    public String                           message2{get;set;}
    Public  String getlabelToSearch(){return labelToSearch;}
    Public  Void setlabelToSearch(String labelToSearch){this.labelToSearch=labelToSearch;}
    
    Public  String getlabelToAdd(){return labelToAdd;}
    Public  Void setlabelToAdd(String labelToAdd){this.labelToAdd=labelToAdd;}
    
    
    //constructor
    public SMB_Permission_Set_Ctrl(){
        try{
            if (pPSA==null)             pPSA        = new PermissionSetAssignment();
            if (listPSA == null)        listPSA     = new List<DecoratedPSA>();
            if (listOFPSA == null)      listOFPSA   = new List<PermissionSetAssignment>();
            message1 ='';
            message2 = '';
        }
        catch(Exception e){
            //  ApexPages.addmessage(  new ApexPages.message(ApexPages.severity.ERROR,  e) );
            return;
        }
        
    }
    //function to search the Permission Set
    public PageReference SearchPermissionSet()    {
        String sQueryComp='';
        listPSA.clear();
        string  sQueryCol ='';
        String  sQueryWhere ='';
        String sQuery ='';
        message1 = '';
        message2 ='';
        if(labelToSearch!='-NONE-'){
            labelToSearch='\'%'+labelToSearch+'%\'';
            sQuerycomp+=' AND PermissionSet.Label like '+labelToSearch;
        }
        if((assigneeToSearch!='-NONE-') && (assigneeToSearch!=null)&& (assigneeToSearch!='') ){
            assigneeToSearch='\'%'+assigneeToSearch+'%\'';
            sQuerycomp+=' AND Assignee.Name like '+assigneeToSearch;
            // check if user exist or not
            sQueryCol   ='SELECT PermissionSetAssignment.id,Assignee.Name, PermissionSet.Id, PermissionSet.isOwnedByProfile, PermissionSet.Profile.Name, PermissionSet.Label';
            sQueryCol  +=' FROM PermissionSetAssignment';
            sQueryWhere =' WHERE PermissionSetId IN (SELECT id FROM PermissionSet where IsOwnedByProfile = false )';//and label like \'XXX%\'
            sQuery  = sQueryCol + sQueryWhere + ' AND Assignee.Name like '+assigneeToSearch +' limit 1000';
            
            listOFPSA = Database.query(sQuery);
            if(listOFPSA.size() == 0)
            {
             message1 = System.Label.PSA_Permission_Set_Invalid_User;
             sQueryComp='';
             sQueryCol  ='';
             sQueryWhere ='';
             listPSA.clear();
             return null;
            }
        }       //Requete de recherche de permission set
        sQueryCol   ='SELECT PermissionSetAssignment.id,Assignee.Name, PermissionSet.Id, PermissionSet.isOwnedByProfile, PermissionSet.Profile.Name, PermissionSet.Label';
        sQueryCol  +=' FROM PermissionSetAssignment';
        sQueryWhere =' WHERE PermissionSetId IN (SELECT id FROM PermissionSet where IsOwnedByProfile = false )';//and label like \'XXX%\'
        String  sQueryOrderBy=' ORDER BY Assignee.Name';
        //execution de la requete
        sQuery  = sQueryCol + sQueryWhere + sQuerycomp+sQueryOrderBy+' limit 1000';system.debug(sQuery);
        listOFPSA = Database.query(sQuery);
        integer ind=0;
        //we add each assignee in th list listOFPSA
        for (PermissionSetAssignment ptempoPSA :listOFPSA){
            DecoratedPSA pTempDecoratedPSA = new DecoratedPSA( ptempoPSA);
            //pTempDecoratedPSA.Id                                  =ptempoPSA.id ;
            pTempDecoratedPSA.AssigneeName                          =ptempoPSA.Assignee.Name; 
            pTempDecoratedPSA.PermissionSetId                       =ptempoPSA.PermissionSet;
            pTempDecoratedPSA.isOwnedByProfile                      =ptempoPSA.PermissionSet.isOwnedByProfile; 
            pTempDecoratedPSA.psaListIndex                          =ind; 
            pTempDecoratedPSA.selected                              =false;
            listPSA.add(pTempDecoratedPSA);
            ind++;
        }
        if(ind == 0){
             message1 = System.Label.PSA_Permission_Set_No_Records_Found;
         }
        return null;
    }
    
    //list to populate the permission set picklist
    public List<SelectOption> getPermissionSetOptions() {
        
        List<SelectOption> listOptionPermSet = new List<SelectOption>();
        List<PermissionSet> listPermSet= [  SELECT Label FROM PermissionSet WHERE IsOwnedByProfile = false
                                         ];
        listOptionPermSet.add(new SelectOption('-NONE-','-NONE-'));
        for (PermissionSet pPs: listPermSet){
            listOptionPermSet.add(new SelectOption(pPs.Label,pPs.Label));
        }
        return listOptionPermSet;
    }
    
    //remove a list of assignne from a permission Ser
    public PageReference RemoveAssignements(){
         message1 = '';
         message2 ='';
         if (listPSA.size() >0){
        List <PermissionSetAssignment> selectedAssignement=new List <PermissionSetAssignment>();
        for( DecoratedPSA currentPsa:   listPSA){
            if(currentPsa.selected==true){
                selectedAssignement.add(currentPsa.pPSA);
            } 
        }
         system.debug('to delete '+selectedAssignement);
         if(selectedAssignement.size() >0)
         {
            labelToSearch=selectedAssignement[0].PermissionSet.Label;
            system.debug('labelToSearch'+selectedAssignement);
            try{
               
                delete selectedAssignement;
                
            }
            catch(DMLexception e){
                system.debug('error message'+e.getmessage());  
            }
            return SearchPermissionSet() ;
         }
         else
         {
            message1 = System.Label.PSA_Permission_Set_Provide_Userdetails;
             return null;}
        }
        else
        {message1 = System.Label.PSA_Permission_Set_Provide_User;
        return null;}
    }
    
    //get the user hwo will have the permission set
    public user getsearchUserToAdd(){
        return [ SELECT Name FROM User limit 1];
    }
    
    //assign a Permission Set to an User
    public PageReference assignPSetToUser()
    {
    message1 ='';
    message2 ='';
        if (labelToAdd != '-NONE-' && userId != null){
            PermissionSetAssignment tempoPSA= new PermissionSetAssignment(); 
            tempoPSA.AssigneeId=userId;
            tempoPSA.PermissionSetId=[select id from PermissionSet where PermissionSet.Label=:labelToAdd][0].id; 
            system.debug('permission set assignement'+tempoPSA);
           try{
                      insert tempoPSA;
                         message2 = 'Persmission Set '+ labelToAdd +' is assigned to '+ UserName ;
                         labelToAdd= '-NONE-';
                 
            }
            catch(Dmlexception e){
                System.debug(''+e.getMessage());
            }
        }
        else
         message2 = System.Label.PSA_Permission_Set_Provide_User;
         return null;
     }
}