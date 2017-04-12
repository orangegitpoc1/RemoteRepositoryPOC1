/*        [15/10/27] OLE UST-1243/WIT-2164 modifiy for OME: split OLI list into a "main" SAMBA list and an secondary "OME" list for OME only product. Note that OME list
                    is NOT a detail list of elements of main list. This is separate list, products are either showing up in the top main list or in the bottom OME one.
                    Both lists are managed in a map of list (mapSubDomainOLI) which has "OME" or "SMB" as keys, SMB meaning non OME product
     * */

public class SMBW3_OptyLine_VFCE {
    // apex/SMBW3_OptyLine_Step1?OptyId=006c000000D67L9
    // https://samba-csg--devolm--c.cs14.visual.force.com/apex/SMBW3_OptyLine_Step1?id=006c000000D67L9
    // https://samba-csg--intw20--c.cs23.visual.force.com/apex/SMBW3_OptyLine_Step1?id=00618000002LyO7
    // apex/SMBW3_OptyLine_Step1?id=006c000000D67L9
    
        private ApexPages.StandardController    scOpportunity;                      //Opportunity
        public  Opportunity                     oOpportunity         {get;set;}     //Parent Opportunity of OLIs
        //public  Pricebook2                      oOptyPriceBook       {get;set;}     //Pricebook defined on opportunity
        public  PriceBookEntry                  oPriceBookEntry      {get;set;}
        public  list<PriceBookEntry>            listPriceBookEntry   {get;set;}
    
        
        //OLI declarations
        public  class DecoratedOLI {                                            // Decorate OLI
           public OpportunityLineItem oOLI { get; private set; } 
           
           public DecoratedOLI (OpportunityLineItem oOLI) {         
                this.oOLI       = oOLI;                             
                this.ilistIndex = 0;
            }
            public string  sProductName   {get;set;}
            public string  sOMEProductCategory    {get;set;}
            
            public string  sProductCode   {get;set;}
            public string  sDomain      {get;set;}
            public string  sSubDomain   {get;set;} 
            public decimal dWQuantity   {get;set;}
            public double  cWProdTCV    {get;set;}
            public integer iListIndex {get;set;}  //used locally to identify row selected in search returned list
            public boolean bExpandLine  {get;set;}  //Expand Line display on 2 rows to display more columns
           // public boolean bIsOMEVAS    {get;set;}  // VAS Product will be displayed differently. As of end Dec 15 on PoC we don't know yet exactly how
                                                    // to identify VAS product, so we add a wrapper bolean for display which will be set from getMapSubDomain 
                                                    // when iterating on products
            public boolean bIsOMECountryVisibility    {get;set;}     // Mobility VAS ,M2M Product will be displayed differently. It will check value for OME Product Type
            public boolean bDisableSuspensionReason {get;set;} // boolean for enabling suspenson reason when status is cust. def.
        }
        public  list<DecoratedOLI>              listOLI           {get;set;}    //List of non OME OLI (i.e.: context Get or Keep) 
        public  list<DecoratedOLI>              listOLIOME        {get;set;}    // List of OLI with Context Cnxn (OME Connections)
        public  map<string,list<DecoratedOLI>>  mapSubDomainOLI      {get;set;}    // a map of OLIs with context as key KeetGet, Cnxn or VAS
        //public  Id                              idSelectedOLI     { get;set;}   //OLI  Id to use to Save OLI
        //public  integer                         iSelectedOLIIndex {get;set;}    // index in list of OLI that has been clicked on to save OLI

        public  User                            loggedInUser;                   // Create here rather than local to constructor to prevent recalling same routine for multiple constructor calls 
        public  boolean                         bHasOMEProducts   {get;set;}    // if false do not dislay OME section including hiding header
        
        // Store various aggregated fields (TCV, etc...) we compute them in the controller since we have all the info at hand, 
        // no need to go back to db to run group by SOQL requests
        public class OLIAggregates {        
            public OLIAggregates() {
                this.reset();
            }
            public void reset() {
                this.dSumOTCSMB       =0;
                this.dSumMRCSMB       =0;
                this.dMaxTermSMB      =0;
                this.dSumTCVSMB       =0;
                this.dSumTNIOVIntlSMB =0;
                this.dSumTCVIntlFRSMB =0;
                this.dSumDeltaCAFRSMB =0;

                this.dSumOTCOME       =0;
                this.dSumMRCOME       =0;
                this.dMaxTermOME      =0;
                this.dSumTCVOME       =0;
                this.dSumTNIOVIntlOME =0;
                this.dSumTCVIntlFROME =0;
                this.dSumDeltaCAFROME =0;

                this.dSumOTCTOT       =0;
                this.dSumMRCTOT       =0;
                this.dMaxTermTOT      =0;
                this.dSumTCVTOT       =0;
                this.dSumTNIOVIntlTOT =0;
                this.dSumTCVIntlFRTOT =0;
                this.dSumDeltaCAFRTOT =0;
            }
            public  double   dSumOTCSMB       {get;set;}      //Aggregate non OME lines SMB
            public  double   dSumMRCSMB       {get;set;}     
            public  double   dMaxTermSMB      {get;set;}     
            public  double   dSumTCVSMB       {get;set;}     
            public  double   dSumTNIOVIntlSMB {get;set;}     
            public  double   dSumTCVIntlFRSMB {get;set;}     
            public  double   dSumDeltaCAFRSMB {get;set;}     
 
                        
            public  double   dSumOTCOME       {get;set;}      //Aggregate  OME lines
            public  double   dSumMRCOME       {get;set;}     
            public  double   dMaxTermOME      {get;set;}     
            public  double   dSumTCVOME       {get;set;}     
            public  double   dSumTNIOVIntlOME {get;set;}     
            public  double   dSumTCVIntlFROME {get;set;}     
            public  double   dSumDeltaCAFROME {get;set;}     

            public  double   dSumOTCTOT       {get;set;}      //Aggregate TCV of all lines: should be equal to Opty.Amount
            public  double   dSumMRCTOT       {get;set;}     
            public  double   dMaxTermTOT      {get;set;}     
            public  double   dSumTCVTOT       {get;set;}     
            public  double   dSumTNIOVIntlTOT {get;set;}     
            public  double   dSumTCVIntlFRTOT {get;set;}     
            public  double   dSumDeltaCAFRTOT {get;set;}     
        }
        public OLIAggregates                    oOLIAggregates {get;set;}

        // Store collection of OLI (Opty Line Item) Ids that have been expanded in display
        // We use it to redisplay OLIs expanded again when refreshing display. This is for display only, not store in db
        public set<Id>      setExpandedOLI    {get;set;}
        
        //Product2 declarations
        public  Product2                        oProduct2   {get;set;}
        public  class DecoratedProduct2 {                                           // Decorate Product2 (i.e.: actually no more than a structure containing another existing structure but I love object fancy vocabulary, so V2.0) 
           public Product2 oProduct2 { get; set; }                          // with Keep/Get members keep/get is used in the search list output by user to check
           public DecoratedProduct2 (Product2 oProduct2) {                          // if (s)he wants to add one or 2 products with keep and/or get context
                this.oProduct2        = oProduct2;                                          // In hte
                this.bKeep            = false;
                this.bGet             = false;
                this.PriceBookEntryId = null;
                this.ilistIndex       = 0;
            }
            public boolean bKeep            {get;set;}
            public boolean bGet             {get;set;}
            public ID      PriceBookEntryId {get;set;}  // Id of PBE through which the product was found (i.e.: we search product among the PBE available for the opty)
            public decimal dUnitPrice       {get;set;}
            public integer iListIndex       {get;set;}  //used locally to identify row selected in search returned list
        }
        public  list<DecoratedProduct2>         listProduct2 {get;set;}             //To display search results. Decorated with bKeep/bGet 
                                                                                    //to allow selection for creation of either mode (create 
                                                                                    //2 OLIs if both selected)
    
        public  Id                              idSelectedProduct    {get;set;}     //Product Id to use to create OLI
        public  integer                         iSelectedProduct2Index {get;set;}   // index in list of search product that has been clicked on to create product
    
        // variables for product search with pagination
        private string                          sQuery {get;set;} 
    
    
        //--------------------------- Constructor -------------------------------------------
        public SMBW3_OptyLine_VFCE(ApexPages.StandardController standardController)
        {
            string sConstructorStep = 'Step00';
           
            try
            {
                // store a reference to the standard controller
                if (scOpportunity == null ) scOpportunity = standardController;
        
                //retrieve Opportunity
                if(!Test.isRunningTest()) 
                scOpportunity.addfields(new List<String>{'currencyIsoCode','pricebook2Id','Id','Name','SMB_OPP_TCV__c', 'SMB_Product_Amount_Overlay__c','CloseDate'} );
                oOpportunity = new Opportunity();
                oOpportunity =(Opportunity)scOpportunity.GetRecord();
                System.debug('------------------------FIRST------------------');
                // In SAMBA version up to 3.0 there is only the standard price book
                if (oOpportunity.priceBook2Id == null)
                {
                    List<PriceBook2> priceBookList = [select id from PriceBook2 where name = 'Standard Price Book' LIMIT 1];
                    if(priceBookList.size() > 0)
                    oOpportunity.priceBook2Id = priceBookList[0].id;
                    //update oOpportunity; ==> No DML in constructor, but that's ok, DML will happen implicitely when adding OLIs
                    //If we want to have multiple PB in the future we'll add a button "Choose PB" 
                }
                System.debug('------------------------SECOND------------------');        
                //bShowSaveButton = true; //display button by default, invalidate by exception

                // init aggregates (note: method populates map in all cases, no need check for null)
                if (oOLIAggregates == null) {
                    oOLIAggregates = new OLIAggregates();

                }

                // init set of OLI to display in expanded mode
                if (setExpandedOLI == null) {
                    setExpandedOLI = new set<Id>();

                }

                //retrieve existing non OME OLIs if any (i.e.: Products line of context Keep or Get but neither VAS no Cnxn)
                sConstructorStep = 'Step02a';
                System.debug('------------------------THIRD------------------');  
                  System.debug('oOpportunity.id '+ oOpportunity.id);                         
                // Let's retrieve with a singel SOQL all OLIs browken down as 2 sublists by key Domain (OME or SMB)
                if ( mapSubDomainOLI == null) mapSubDomainOLI = getMapSubDomainOLI(oOpportunity.id, oOLIAggregates, setExpandedOLI);
                  System.debug('oOpportunity.id '+ oOpportunity.id); 
                if (listOLI == null) 
                {

                    sConstructorStep = 'Step02a-1-Non-OME-Products';
                    listOLI = new list<DecoratedOLI>();
                    listOLI = mapSubDomainOLI.get('SMB');
                    sConstructorStep = 'Step02a-1-Non-OME-Products';
                    if (listOLI.size() > 999) 
                        {

                            ApexPages.addmessage(  new ApexPages.message(ApexPages.severity.ERROR, Label.OLI_Too_Many_OLI + 'Constructor Step:' + sConstructorStep ));
                        }





                }        
        
                //retrieve existing Cnxn OME OLIs if any (i.e.: Products line of context Cnxn)
                sConstructorStep = 'Step02b';
                bHasOMEProducts = false;
                if (listOLIOME == null) 
                {
                    sConstructorStep = 'Step02b-1-OME';
                    listOLIOME = new list<DecoratedOLI>();
                    listOLIOME = mapSubDomainOLI.get('OME');
                    sConstructorStep = 'Step02b-1-OME';
                    if (listOLIOME.size() > 999) 
                        {
                            ApexPages.addmessage(  new ApexPages.message(ApexPages.severity.ERROR, Label.OLI_Too_Many_OLI + 'Constructor Step:' + sConstructorStep ));


                        }
                    if (listOLIOME.size() > 0) bHasOMEProducts = true;
                }        

                // Init oProduct and listProduct Creation
                sConstructorStep = 'Step04';
                if(oProduct2 == null)       oProduct2       = new Product2(); 
                if (listProduct2 == null)   listProduct2    = new List<DecoratedProduct2>();
                
                sConstructorStep = 'Step05';
                // Init Pricebook and list 
                if (oPriceBookEntry == null)      oPriceBookEntry       = new PriceBookEntry(); 
                if (listPriceBookEntry == null)   listPriceBookEntry    = new List<PriceBookEntry>();

                sConstructorStep = 'Step06';
                // Search defaulting section. Based on User Region look in Custom setting Sales_Region for default Domain or channel search
                if (loggedInUser == null) loggedInUser = [SELECT SMB_Sales_Region__c,SMB_Sales_Cluster__c From User WHERE Id =: UserInfo.getUserId()];

                SMB_Setting_Region__c ssr;
                
                if(loggedInUser.SMB_Sales_Region__c!=null)
                    ssr = SMB_Setting_Region__c.getValues(loggedInUser.SMB_Sales_Region__c+' Region'); 



                





                if(ssr!=null && ssr.Domain__c!=null)  oProduct2.Domains__c = ssr.Domain__c;
                    
                if(ssr!=null && ssr.Channel__c!=null)
                {
                    // cluster condition added for Russia so that for Russian User channel set to "RUS"                    
                    if(loggedInUser.SMB_Sales_Cluster__c!=null && loggedInUser.SMB_Sales_Cluster__c==System.label.OLI_TEK_Product_Russia)
                        oProduct2.Channel__c = System.label.OLI_TEK_Product_Rus;
                    else
                         oProduct2.Channel__c = ssr.Channel__c;
                }



                
                return;
            }
            catch(Exception e)
            {
                ApexPages.addmessage(  new ApexPages.message(ApexPages.severity.ERROR, Label.OLI_Constructor_error + ' ' + e)  );
                return;
            }
        }
        
        // Search products matching input criteria (display first page of records).
        public PageReference SearchProduct()    {
    
            /* ****************************************
             [15/10/27] OLE UST-1243/WIT-2164 Removing this init as part of OME product revamp: in this version I'll compute all aggregated values at Opty Level  while iterating on 
             OLIs in main getmapSubDomain loop rather than re-sending a query to db. Opty level info is queried once an dfor all during construction and not queried again.
             *******************************************
            if(oOpportunity.pricebook2Id == null){
                oOpportunity.pricebook2Id = [SELECT pricebook2Id FROM Opportunity WHERE Id =: oOpportunity.Id].pricebook2Id;
            }
            
            if (oOpportunity.priceBook2Id == null)
            {
                List<PriceBook2> priceBookList = [select id from PriceBook2 where name = 'Standard Price Book' LIMIT 1];
                if(priceBookList.size() > 0)
                oOpportunity.priceBook2Id = priceBookList[0].id;
            }         
             **************************************** */
        

            listProduct2.clear();
            if ((oProduct2.name == null) && (oProduct2.productCode == null) && (oProduct2.domains__c == null) && (oProduct2.channel__c == null))
            {
                ApexPages.addmessage(  new ApexPages.message(ApexPages.severity.ERROR, Label.OLI_Enter_Product_name_or_code  ));
            } else 
            {
                string sQueryCol   = 'SELECT id, product2id, name, unitPrice, productCode, product2.channel__c '; 
                       sQueryCol  += ' ,product2.domains__c ,product2.Sub_Domain__c,product2.OME_Product_Category__c, product2.SMB_PRD_Strategy_Type__c ';
                       string sQueryWhere = ' FROM PriceBookEntry where product2.isActive = true ';
                                                                         sQueryWhere += ' and pricebook2id = \''                      + oOpportunity.pricebook2Id + '\'';
                                                                         sQueryWhere += ' and currencyIsoCode = \''                   + oOpportunity.currencyIsoCode + '\'';
                       if (oProduct2.name != null)                       sQueryWhere += ' and name like \''                           + '%' + String.escapeSingleQuotes(oProduct2.name).replace('*','%')  + '%\'';
                       if (oProduct2.productCode != null)                sQueryWhere += ' and productCode    like \''                 + String.escapeSingleQuotes(oProduct2.productCode).replace('*','%')  + '%\'';
                       if (oProduct2.channel__c != null)                 sQueryWhere += ' and product2.channel__c    = \''            + String.escapeSingleQuotes(oProduct2.channel__c)  + '\'';
                       if (oProduct2.domains__c != null)                 sQueryWhere += ' and product2.domains__c    = \''            + String.escapeSingleQuotes(oProduct2.domains__c)  + '\'';
                       if (oProduct2.Sub_Domain__c != null)              sQueryWhere += ' and product2.Sub_Domain__c = \''            + String.escapeSingleQuotes(oProduct2.Sub_Domain__c)  + '\'';
                       if (oProduct2.SMB_PRD_Strategy_Type__c  != null)  sQueryWhere += ' and product2.SMB_PRD_Strategy_Type__c  = \''+ String.escapeSingleQuotes(oProduct2.SMB_PRD_Strategy_Type__c)  + '\' ' ;

                
                //init search pagination with record count() based on current parameters
                string sQueryCount = 'select count() ' + sQueryWhere + ' LIMIT 9999';
                //ApexPages.addmessage(new ApexPages.message(    ApexPages.severity.ERROR,'sQueryCount: ' + sQueryCount     ));            
                
                // get first page of data
                sQuery  = sQueryCol + sQueryWhere + ' order by name ';

                //ApexPages.addmessage(new ApexPages.message(    ApexPages.severity.INFO,'sQueryInitialSet: ' + sQueryInitialSet     ));            
                //ApexPages.addmessage(new ApexPages.message(    ApexPages.severity.INFO,'Search iPageSize: ' + iPageSize     ));            
                //ApexPages.addmessage(new ApexPages.message(    ApexPages.severity.INFO,'Search iNbOfPages: ' + iNbOfPages     ));            
                //ApexPages.addmessage(new ApexPages.message(    ApexPages.severity.INFO,'Search iPageNumber: ' + iPageNumber     ));            
                //ApexPages.addmessage(new ApexPages.message(    ApexPages.severity.INFO,'Search iTotalNoOfRecs: ' + iTotalNoOfRecs     ));            
                
                listPriceBookEntry = Database.query(sQuery);
                
                // listPriceBookEntry must have been initialized in constructor
                integer ii = 0;
                for (PriceBookEntry oPBE : listPriceBookEntry) 
                {
                    //if (ii > iSearchLimit - 2) 
                    //{
                    //    ApexPages.addmessage(new ApexPages.message(   ApexPages.severity.WARNING, Label.OLI_Max_product_search    ));            
                    //    break;
                    //}
                    DecoratedProduct2 oTempDecoratedProduct2 = new DecoratedProduct2(new Product2(
                         Id                         = oPBE.product2id 
                        ,name                       = oPBE.name
                        ,productCode                = oPBE.productCode
                        ,domains__c                 = oPBE.product2.domains__c
                        ,sub_domain__c              = oPBE.product2.sub_domain__c
                        ,channel__c                 = oPBE.product2.channel__c
                        ,SMB_PRD_Strategy_Type__c   = oPBE.product2.SMB_PRD_Strategy_Type__c
                        ,OME_Product_Category__c    =  oPBE.product2.OME_Product_Category__c    
                    ));
                    oTempDecoratedProduct2.bKeep            = false;
                    oTempDecoratedProduct2.bGet             = false;
                    oTempDecoratedProduct2.PriceBookEntryId = oPBE.id;
                    oTempDecoratedProduct2.dUnitPrice       = oPBE.UnitPrice;
                    oTempDecoratedProduct2.iListIndex       = ii;
                    
                    listProduct2.add(oTempDecoratedProduct2);   // don't care of keep/get attribute at this stage, this will be checked by user as needed when selected the product)
                    ii++;
                }
                
                if (ii == 0) 
                {
                    ApexPages.addmessage(new ApexPages.message(   ApexPages.severity.ERROR, Label.OLI_No_product_returned    ));            
                }
    
            }
            
            return null; 
        }
    
        public PageReference SearchProductOffset()    {
    
            //integer iSearchLimit = 11; // will have ro replace that by a custom setting at some point 
            //Initiate pagination

            listProduct2.clear();

            //ApexPages.addmessage(new ApexPages.message(    ApexPages.severity.INFO,'sQueryNext: ' + sQueryNext     ));            
            //ApexPages.addmessage(new ApexPages.message(    ApexPages.severity.INFO,'SearchNext iPageSize: ' + iPageSize     ));            
            //ApexPages.addmessage(new ApexPages.message(    ApexPages.severity.INFO,'SearchNext iNbOfPages: ' + iNbOfPages     ));            
            //ApexPages.addmessage(new ApexPages.message(    ApexPages.severity.INFO,'SearchNext iPageNumber: ' + iPageNumber     ));            
            //ApexPages.addmessage(new ApexPages.message(    ApexPages.severity.INFO,'SearchNext iTotalNoOfRecs: ' + iTotalNoOfRecs     ));            
            
            listPriceBookEntry = Database.query(sQuery);
            // listPriceBookEntry must have been initialized in constructor
            integer ii = 0;
            for (PriceBookEntry oPBE : listPriceBookEntry) 
            {
                DecoratedProduct2 oTempDecoratedProduct2 = new DecoratedProduct2(new Product2(
                    Id                         = oPBE.product2id 
                    ,name                       = oPBE.name
                    ,productCode                = oPBE.productCode
                    ,domains__c                 = oPBE.product2.domains__c
                    ,sub_domain__c              = oPBE.product2.sub_domain__c
                    ,channel__c                 = oPBE.product2.channel__c
                    ,SMB_PRD_Strategy_Type__c   = oPBE.product2.SMB_PRD_Strategy_Type__c
                ));
                oTempDecoratedProduct2.bKeep            = false;
                oTempDecoratedProduct2.bGet             = false;
                oTempDecoratedProduct2.PriceBookEntryId = oPBE.id;
                oTempDecoratedProduct2.dUnitPrice        = oPBE.UnitPrice;
                oTempDecoratedProduct2.iListIndex       = ii;
                
                listProduct2.add(oTempDecoratedProduct2);   // don't care of keep/get attribute at this stage, this will be checked by user as needed when selected the product)
                ii++;
            }
            
            if (ii == 0) ApexPages.addmessage(new ApexPages.message(   ApexPages.severity.ERROR, Label.OLI_No_product_returned    ));            
            
            
            return null; 
        }
    

    
    
        //add Opportunity Line Item. If both Keep and Get we'll add 2 lines. If none return error
        public PageReference addOLI()   
        {
            //Get params set from the UI (emulating passing parameters, not ideal but I didn't find any better so far)
            Id      IdProductToAdd              = idSelectedProduct;
            integer iSelectedProduct2Index      = iSelectedProduct2Index;
    
            if (    (listProduct2.get(iSelectedProduct2Index).bKeep == false) 
                 && (listProduct2.get(iSelectedProduct2Index).bGet == false)
               )
            {
                ApexPages.addmessage(
                    new ApexPages.message(  ApexPages.severity.Error, Label.OLI_Context_Must_Be_Keep_or_Get ));
            } else
            {
                //ApexPages.addmessage(
                //    new ApexPages.message(ApexPages.severity.INFO, 'IdProductToAdd: ' + IdProductToAdd + ' K/G: ' + listProduct2.get(iSelectedProduct2Index).bKeep + '/' + listProduct2.get(iSelectedProduct2Index).bGet
                //));
                try 
                {
                    if (listProduct2.get(iSelectedProduct2Index).bKeep == true) 
                    {
                        
                        CreateNewOLI(
                             listProduct2.get(iSelectedProduct2Index).PriceBookEntryId
                            ,oOpportunity.Id
                            ,'Keep'
                            ,listProduct2.get(iSelectedProduct2Index).dUnitPrice
                            ,listProduct2.get(iSelectedProduct2Index).oProduct2.Name
                            ,listProduct2.get(iSelectedProduct2Index).oProduct2.ProductCode
                            //,listProduct2.get(iSelectedProduct2Index).oProduct2.OME_Product_Category__c    
                            //,listOLI.size()
                        );












                    } // end of adding a Keep OLI

                    if (listProduct2.get(iSelectedProduct2Index).bGet == true) 
                    {



                        CreateNewOLI(
                             listProduct2.get(iSelectedProduct2Index).PriceBookEntryId
                            ,oOpportunity.Id
                            ,'Get'
                            ,listProduct2.get(iSelectedProduct2Index).dUnitPrice
                            ,listProduct2.get(iSelectedProduct2Index).oProduct2.Name
                            ,listProduct2.get(iSelectedProduct2Index).oProduct2.ProductCode
                           // ,listProduct2.get(iSelectedProduct2Index).oProduct2.OME_Product_Category__c 
                            //,listOLI.size()
                        );












                    } // end of adding a Get or Kepp  OLI





                    //finally let's reset the keep/get flag on searched product list (for non OME products)
                    listProduct2.get(iSelectedProduct2Index).bKeep = false;
                    listProduct2.get(iSelectedProduct2Index).bGet = false;



                    //Refresh all display lists, sorted, maybe not optimal, but we need the roundtrip to db to read the new product TCV and other WF related values
                    //the following accesses should be safe since lists are supposed to be initialized in constructor...
                    //bHasOMEProducts = true;
                    listOLI.clear();
                    listOLIOME.clear();
                    mapSubDomainOLI.clear();
                    mapSubDomainOLI = getMapSubDomainOLI(oOpportunity.id, oOLIAggregates, setExpandedOLI);
                    listOLI       = mapSubDomainOLI.get('SMB');
                    listOLIOME    = mapSubDomainOLI.get('OME');
                    if (listOLIOME.size() > 0) {bHasOMEProducts = true;} else {bHasOMEProducts = false;}

                    
                }
                catch (Exception e)
                {
                    System.debug('================================>>> Exception SMBW3_OptyLine_VFCE addOLI e:' + e);
                    ApexPages.addmessage(
                        new ApexPages.message(ApexPages.severity.ERROR, Label.OLI_Error_Adding_OLI + ' (Method addOLI) Opty Id: ' + oOpportunity.id + ' Err: ' + e));

                } 
                
            }
    
            return null; 
        }
        

    
        //----------------- save OLI, called via link on OLI record -----------------------------
        /****** NOt Used Anymore
        public PageReference saveOLI() 
        {
                            try
            {
                Id      IdOLIToSave             = idSelectedOLI;
                integer iSelectedOLIIndex       = iSelectedOLIIndex;
                
                update listOLI.get(iSelectedOLIIndex).oOLI;
    
                //Refresh display list, sorted, not very efficient I know, but I need the roundtrip to db to read the new TCV value
                listOLI.clear();
                listOLI = getListOLI(oOpportunity.Id); 
    
                return null;
            }
            catch (Exception e)
            {
                // Not very elegant but in case of crash, trying to recover by navigating back to where I was
                //PageReference pageRef = new PageReference('/' + scOpportunity.GetRecord().id);
                system.debug('=====> saveOLI before returning self in catch with e: ' + e);
                return new PageReference('/apex/SMBW3_OptyLine_Step1?id=' + oOpportunity.id);

            }
        }
        ***************************************/
        
        //----------------- Navigate back to Opty detail -----------------------------
        public PageReference goToOptyDetail() 
        {
            return new PageReference('/' + oOpportunity.id);
        }
    
        public PageReference saveAllOLI() 
        {
            try
            {
                list<OpportunityLineItem> listOLIToUpdate = new list<OpportunityLineItem>();

                if (listOLI != null) 
                {
                    for (DecoratedOLI oDecoratedOLI : listOLI)
                    {
                        //Those 4 fields cannot be null on insertion/update (mandatory in standard UI anyway)
                        if (oDecoratedOLI.oOLI.One_Off_Charge__c == null)   oDecoratedOLI.oOLI.One_Off_Charge__c = 0;
                        if (oDecoratedOLI.oOLI.Term_in_months__c == null)   oDecoratedOLI.oOLI.Term_in_months__c = 0;
                        if (oDecoratedOLI.oOLI.MRC__c            == null)   oDecoratedOLI.oOLI.MRC__c = 0;
                        if ( (oDecoratedOLI.oOLI.Quantity        == null) ||
                             (oDecoratedOLI.oOLI.Quantity        == 0)
                            )                                               oDecoratedOLI.oOLI.Quantity = 1;
                        listOLItoUpdate.add(oDecoratedOLI.oOLI);
                    }
                }
                System.debug('None OME listOLI ****' + listOLItoUpdate);
                if (listOLIOME != null) 
                {
                    for (DecoratedOLI oDecoratedOLI : listOLIOME)
                    {
                        //Those 3 fields cannot be null on insertion/update (mandatory in standard UI anyway)
                        if (oDecoratedOLI.oOLI.One_Off_Charge__c == null) oDecoratedOLI.oOLI.One_Off_Charge__c = 0;
                        if (oDecoratedOLI.oOLI.Term_in_months__c == null) oDecoratedOLI.oOLI.Term_in_months__c = 0;
                        if (oDecoratedOLI.oOLI.MRC__c            == null) oDecoratedOLI.oOLI.MRC__c = 0;
                        listOLItoUpdate.add(oDecoratedOLI.oOLI);
                    }
                }
                System.debug('ALL listOLI ****' + listOLItoUpdate);
                update listOLIToUpdate;
    

                //Refresh display list, sorted, not very efficient I know, but I need the roundtrip to db to read the new
                // Opty Product TCV value (note: this applies to OLI level, not at Opty level which doesn't need to be queried again, see below)
                if (mapSubDomainOLI != null)  mapSubDomainOLI.clear();
                mapSubDomainOLI = getMapSubDomainOLI(oOpportunity.id, oOLIAggregates,setExpandedOLI);
                //the following should be safe since list are supposed to be initiated in constructor
                listOLI.clear();

                listOLIOME.clear();
                listOLI    = mapSubDomainOLI.get('SMB');
                listOLIOME = mapSubDomainOLI.get('OME');
                if (listOLIOME.size() > 0) {bHasOMEProducts = true;} else {bHasOMEProducts = false;}

                /* ****************************************
                 [15/10/27] OLE UST-1243/WIT-2164 This is not needed anymore as we compute aggregate at opty level on the fly while iterating on OLIs
                 Also note for maintenance: if you re-introduce an SOQL at Opty level then do it in a method not directy here in the code
                 *******************************************
                oOpportunity = [SELECT currencyIsoCode, pricebook2Id, Name, SMB_OPP_TCV__c, SMB_Product_Amount_Overlay__c FROM Opportunity
                                WHERE Id =: oOpportunity.Id]; 


                ******************************************* */    
                return null;
            }
            catch (Exception e)
            {
                System.debug('================================>>> Exception in SMBW3_OptyLine_VFCE saveAllOLI e:' + e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, '(method saveAllOLI) e: ' + e.getMessage()));


                return null;

                // nah.... not a good idea to hide exception, makes the page nor working without error messages
                //return new PageReference('/apex/SMBW3_OptyLine_Step1?id=' + oOpportunity.id);


            }
        }
        
        //------------------- delete OLI, called via apex:function itself called from link on OLI record ------------
        public PageReference deleteOLI() 
        {
            try
            {
                integer iSelectedOLIIndex  = Integer.valueof(Apexpages.currentPage().getParameters().get('rowNumberOLI'));

                string  sSelectedOLISubDomain = Apexpages.currentPage().getParameters().get('rowSubDomainOLI'); //pok
                
                if (sSelectedOLISubDomain != 'OME') delete listOLI.get(iSelectedOLIIndex).oOLI; //pok
                if (sSelectedOLISubDomain == 'OME') delete listOLIOME.get(iSelectedOLIIndex).oOLI; //pok

                //Refresh display list, sorted, not very efficient I know, but I need the roundtrip to db to read the new TCV value
                if (mapSubDomainOLI != null)  mapSubDomainOLI.clear();
                mapSubDomainOLI = getMapSubDomainOLI(oOpportunity.id, oOLIAggregates, setExpandedOLI);
                // Check if anything to display for OME list, if not bHasOMEProducts will turn off section
                if (mapSubDomainOLI.get('OME') != null) 
                {
                    if (mapSubDomainOLI.get('OME').size() > 0) {bHasOMEProducts = true;} else {bHasOMEProducts = false;}
                }
                //the following should be safe since list are supposed to be initiated in constructor
                listOLI.clear();

                listOLIOME.clear();

                listOLI    = mapSubDomainOLI.get('SMB');
                listOLIOME = mapSubDomainOLI.get('OME');

                                
                return null;
            }
            catch (Exception e)
            {
                System.debug('================================>>> Exception in deleteOLI e:' + e);
                ApexPages.addmessage(  new ApexPages.message(ApexPages.severity.ERROR, 'Exception in deleteOLI: ' + e ));
                return null;
                // nah.... not a good idea to hide exception, makes the page nor working without error messages
                //return new PageReference('/apex/SMBW3_OptyLine_Step1?id=' + oOpportunity.id);
            }
        }
    
        //------------------- Expand Line on 2 rows to show more fields -------------------
        public PageReference ExpandLine() 
        {
            integer iSelectedOLIIndex = Integer.valueof(Apexpages.currentPage().getParameters().get('rowNumberOLI'));
            Id      idSelectedOLI     = (Apexpages.currentPage().getParameters().get('idSelectedOLI'));
            try
            {
                //Not refreshing the data from db, we do that when we save from saveALLOLI method
                if (listOLIOME.get(iSelectedOLIIndex).bExpandLine == true)
                {
                    listOLIOME.get(iSelectedOLIIndex).bExpandLine = false;
                    setExpandedOLI.remove(idSelectedOLI);   //remove OLI from collection of expanded lines
                } else
                {
                    listOLIOME.get(iSelectedOLIIndex).bExpandLine = true;
                    setExpandedOLI.add(idSelectedOLI);      //add OLI to collection of expanded lines
                }                                
                return null;
            }
            catch (Exception e)
            {
                // Not very elegant but in case of crash, trying to recover by navigating back to where I was
                //PageReference pageRef = new PageReference('/' + scOpportunity.GetRecord().id);

                return new PageReference('/apex/SMBW3_OptyLine_Step1?id=' + oOpportunity.id);

            }
        }
        //--------------- Private util methods -----------------------------------------

    
        //getMapSubDomainOLI: util method to retrieve list(s) of OLI if any exist on current Opty. 
        // We return 2 separate lists using SubDomain as filter
        //      OME       ==> OME (Connections and VAS)
        //      SMB       ==> "SAMBA": all the rest. (Note: M2M/Machine2Machine IOT are not in OME domain)
        @TestVisible
        private map<string,list<DecoratedOLI>> getMapSubDomainOLI(
                                                     Id IdOpty                      //in: Opty id 
                                                    ,OLIAggregates oOLIAggregates   //in/out: reference of an OLIAggregator to populate with aggregate computed on the fly
                                                    ,set<Id> setExpandedOLI         //in: set of OLIs that must be redisplayed in expanded state
        )
        {
       
            transient map<string,list<DecoratedOLI>> mapSubDomainOLI      = new map<string,list<DecoratedOLI>>();
            transient list<OpportunityLineItem>      listOLIUndecorated = new list<OpportunityLineItem>();            //temp to retrieve from db. Build a sQuery and loop on database.query(sQuery) would work too
            //transient DecoratedOLI                oTotalOLI          = new DecoratedOLI(new OpportunityLineItem()); // dummy line to display Opty TCV
            //oTotalOLI.oOLI.TotalPrice = 0;


            listOLIUndecorated = [

                select id, priceBookEntryId, priceBookEntry.name, priceBookEntry.productCode
                ,priceBookEntry.product2.Domains__c 
                ,priceBookEntry.product2.Sub_Domain__C
                ,priceBookEntry.product2.OME_Product_Category__c
                ,SMB_OPPPR_Context__c
                ,OpportunityId
                ,One_Off_Charge__c
                ,Term_in_months__c
                ,MRC__c 
                ,SMB_OPPPR_Net_Incremental_OV__c            /*TNIOV INTL */
                ,SMB_OPPPR_TCV_International__c             /* TCV FR */
                ,SMB_OPPR_CAS_NIOV__c                       /*Delta CA FR */
                ,Quantity 

                ,TotalPrice                                 /* TCV */
                ,UnitPrice                                  /* SalesPrice, Will not display. IS mandatory on standard page but we don't want it for now */ 
                ,OME_OPPPR_P_S_Delivery_Country__c          /* OME fields */
                ,OME_OPPPR_Bookable__c                      
                ,OME_OPPPR_P_S_Status__c
                ,OME_OPPPR_Operators__c 
                ,OME_OPPPR_P_S_Probability__c
                ,OME_OPPPR_P_S_Close_Date__c
                ,OME_OPPPR_Contract_Start_Date__c
                ,OME_OPPPR_Contract_End_Date__c
                //,OME_OPPPR_Retention_Order_Value__c         
                //,OME_OPPPR_Acquisition_Contract_Value__c    
                ,OME_OPPPR_W_QTY__c 
                ,OME_OPPPR_W_Total_Contract_Value__c
                ,OME_OPPPR_Reason_for_suspension__c
                from OpportunityLineItem
                where OpportunityId = :IdOpty
                order by OME_OPPPR_P_S_Delivery_Country__c,priceBookEntry.name,SMB_OPPPR_Context__c
              // [AUG2016] UST-01338 Changes in sorting(Sorting by Country) 
              
                LIMIT 1000
            ];

            if(oOLIAggregates != null) oOLIAggregates.reset();
            integer iOME = 0;
            integer iSMB = 0;
            integer iTOT = 0;

             System.debug('t1'); 
            mapSubDomainOLI.put('OME',new list<DecoratedOLI>());
            mapSubDomainOLI.put('SMB',new list<DecoratedOLI>());
            if(listOLIUndecorated != null){ System.debug('t2'); 
            for (OpportunityLineItem oOLIUndecorated : listOLIUndecorated)
            {

                DecoratedOLI oDecoratedOLITemp = new DecoratedOLI(new OpportunityLineItem(

                     Id                                 = oOLIUndecorated.Id 
                    ,PriceBookEntryId                   = oOLIUndecorated.PriceBookEntryId
                    //,SMB_OPPPR_Domain__c              = oOLIUndecorated.priceBookEntry.Product2.Domains__c;
                    //,SMB_OPPPR_Sub_Domain__c          = oOLIUndecorated.PricebookEntry.Product2.Sub_Domain__c
                    ,OpportunityId                      = oOLIUndecorated.OpportunityId
                    //,productCode                      = oOLIUndecorated.productCode  //not writeable, automatically denormalized
                    ,SMB_OPPPR_Context__c               = oOLIUndecorated.SMB_OPPPR_Context__c
                    ,One_Off_Charge__c                  = oOLIUndecorated.One_Off_Charge__c
                    ,Term_in_months__c                  = oOLIUndecorated.Term_in_months__c
                    ,MRC__c                             = oOLIUndecorated.MRC__c 
                    ,SMB_OPPPR_Net_Incremental_OV__c    = oOLIUndecorated.SMB_OPPPR_Net_Incremental_OV__c
                    ,SMB_OPPPR_TCV_International__c     = oOLIUndecorated.SMB_OPPPR_TCV_International__c
                    ,SMB_OPPR_CAS_NIOV__c               = oOLIUndecorated.SMB_OPPR_CAS_NIOV__c
                    ,Quantity                           = oOLIUndecorated.Quantity
                    ,TotalPrice                         = oOLIUndecorated.TotalPrice
                    ,UnitPrice                          = oOLIUndecorated.UnitPrice
                    ,OME_OPPPR_P_S_Delivery_Country__c  = oOLIUndecorated.OME_OPPPR_P_S_Delivery_Country__c
                    ,OME_OPPPR_Bookable__c                   = oOLIUndecorated.OME_OPPPR_Bookable__c
                    ,OME_OPPPR_P_S_Status__c                 = oOLIUndecorated.OME_OPPPR_P_S_Status__c
                    ,OME_OPPPR_Operators__c                  = oOLIUndecorated.OME_OPPPR_Operators__c
                    ,OME_OPPPR_P_S_Probability__c            = oOLIUndecorated.OME_OPPPR_P_S_Probability__c
                    ,OME_OPPPR_P_S_Close_Date__c             = oOLIUndecorated.OME_OPPPR_P_S_Close_Date__c
                    ,OME_OPPPR_Contract_Start_Date__c        = oOLIUndecorated.OME_OPPPR_Contract_Start_Date__c
                    ,OME_OPPPR_Contract_End_Date__c          = oOLIUndecorated.OME_OPPPR_Contract_End_Date__c
                     //,OME_OPPPR_Retention_Order_Value__c      = oOLIUndecorated.OME_OPPPR_Retention_Order_Value__c
                    //,OME_OPPPR_Acquisition_Contract_Value__c = oOLIUndecorated.OME_OPPPR_Acquisition_Contract_Value__c
                    ,OME_OPPPR_Reason_for_suspension__c      = oOLIUndecorated.OME_OPPPR_Reason_for_suspension__c
                    
                ));
                System.debug('t3');
                //complete wrapper decoration
                oDecoratedOLITemp.sProductName  = oOLIUndecorated.priceBookEntry.name;
                oDecoratedOLITemp.sProductCode  = oOLIUndecorated.priceBookEntry.ProductCode;
                oDecoratedOLITemp.sDomain       = oOLIUndecorated.priceBookEntry.Product2.Domains__c;
                oDecoratedOLITemp.sSubDomain    = oOLIUndecorated.PricebookEntry.Product2.Sub_Domain__c;
                oDecoratedOLITemp.dWQuantity    = oOLIUndecorated.OME_OPPPR_W_QTY__c;
                oDecoratedOLITemp.cWProdTCV     = oOLIUndecorated.OME_OPPPR_W_Total_Contract_Value__c;
                oDecoratedOLITemp.sOMEProductCategory       = oOLIUndecorated.priceBookEntry.Product2.OME_Product_Category__c;
System.debug('t4');
                //---------------------------------------Previous Code--------------------------------------
                // VAS Product will be displayed differently. As of end Dec 15 on PoC we don't know yet exactly how to identify VAS product
                // so going for name contains "VAS". Not very smart, but will do for POC. Hopefully before deploying OME we'll have a business
                // decision to have an OME catalogue attribute. At worst we'll have to do a custom setting list (or custom MD type nowadays) to 
                // specificy a list of "VAS" products
                //oDecoratedOLITemp.bIsOMEVAS     = false;
                //if (oDecoratedOLITemp.sProductName.contains('VAS')) 
                //{
                //    oDecoratedOLITemp.bIsOMEVAS     = true;
               // }
                
                //--------------------------------------------------------------------------------------------
               // Mobility VAS ,M2M Product will be displayed differently. It will check value for OME Product Type
                oDecoratedOLITemp.bIsOMECountryVisibility    = false;
                if(oDecoratedOLITemp.sOMEProductCategory != null){
                if (oDecoratedOLITemp.sOMEProductCategory.contains('VAS')) 
                {
                    oDecoratedOLITemp.bIsOMECountryVisibility    = true;
                }
                else if (oDecoratedOLITemp.sOMEProductCategory.contains('M2M')) 
                {
                    oDecoratedOLITemp.bIsOMECountryVisibility    = true;
                }
                else
                  oDecoratedOLITemp.bIsOMECountryVisibility    = false;
                  }
               //---------------------------------------------------------------------------------------------- 
                //----Default Suspension reason is disable only available for status = Cust. Def.
           System.debug('t5');      
           if (oDecoratedOLITemp.oOLI.OME_OPPPR_P_S_Status__c != null){
                  if (oDecoratedOLITemp.oOLI.OME_OPPPR_P_S_Status__c.contains('Cust. Def.')) 
                    oDecoratedOLITemp.bDisableSuspensionReason = true;
                  else 
                    oDecoratedOLITemp.bDisableSuspensionReason = false;
                    }
              System.debug('t5.1');   
                 
                //Those 4 fields must not be 0 or null. Should not happen, more a protection if something goes wrong in an bugged WF or ProcBuilder
                if (oDecoratedOLITemp.oOLI.One_Off_Charge__c == null)       oDecoratedOLITemp.oOLI.One_Off_Charge__c = 0;
                if (oDecoratedOLITemp.oOLI.Term_in_months__c == null)       oDecoratedOLITemp.oOLI.Term_in_months__c = 0;
                if (oDecoratedOLITemp.oOLI.MRC__c            == null)       oDecoratedOLITemp.oOLI.MRC__c = 0;
                if ( (oDecoratedOLITemp.oOLI.Quantity        == null) ||
                     (oDecoratedOLITemp.oOLI.Quantity       == 0)
                    )                                                       oDecoratedOLITemp.oOLI.Quantity = 1;
                System.debug('t6');
                //restore line in its expanded or not expanded state
                oDecoratedOLITemp.bExpandLine   = false;
                if (setExpandedOLI.contains(oOLIUndecorated.Id )) oDecoratedOLITemp.bExpandLine   = true;
                

                //Now add the line to OME list or SMB list (all others)
              
                 System.debug('t6.1');
                if (oDecoratedOLITemp.sSubDomain != 'OME') //pok
                {
                    oDecoratedOLITemp.iListIndex = iSMB;
                    mapSubDomainOLI.get('SMB').add(oDecoratedOLITemp);  
                    iSMB++; 
                    //Aggregate non OME lines
                   if(oDecoratedOLITemp.oOLI.One_Off_Charge__c != null) oOLIAggregates.dSumOTCSMB       += oDecoratedOLITemp.oOLI.One_Off_Charge__c;
                    if(oDecoratedOLITemp.oOLI.MRC__c != null) oOLIAggregates.dSumMRCSMB       += oDecoratedOLITemp.oOLI.MRC__c;
                    if(oDecoratedOLITemp.oOLI.Term_in_months__c != null){
                    if( oDecoratedOLITemp.oOLI.Term_in_months__c > oOLIAggregates.dMaxTermSMB)  oOLIAggregates.dMaxTermSMB= oDecoratedOLITemp.oOLI.Term_in_months__c;
                    }
                    if(oDecoratedOLITemp.oOLI.TotalPrice != null) oOLIAggregates.dSumTCVSMB       += oDecoratedOLITemp.oOLI.TotalPrice;
                    if(oDecoratedOLITemp.oOLI.SMB_OPPPR_Net_Incremental_OV__c!= null)  oOLIAggregates.dSumTNIOVIntlSMB += oDecoratedOLITemp.oOLI.SMB_OPPPR_Net_Incremental_OV__c;
                    if(oDecoratedOLITemp.oOLI.SMB_OPPPR_TCV_International__c!= null) oOLIAggregates.dSumTCVIntlFRSMB += oDecoratedOLITemp.oOLI.SMB_OPPPR_TCV_International__c;
                    if(oDecoratedOLITemp.oOLI.SMB_OPPR_CAS_NIOV__c!= null)oOLIAggregates.dSumDeltaCAFRSMB += oDecoratedOLITemp.oOLI.SMB_OPPR_CAS_NIOV__c;       }
                if (oDecoratedOLITemp.sSubDomain == 'OME') //pok
                {
                    //Aggregate OME lines
                     System.debug('t6.3');
                    oDecoratedOLITemp.iListIndex = iOME;
                    mapSubDomainOLI.get('OME').add(oDecoratedOLITemp);   
                    iOME++;
                    if(oDecoratedOLITemp.oOLI.One_Off_Charge__c != null) oOLIAggregates.dSumOTCOME       += oDecoratedOLITemp.oOLI.One_Off_Charge__c;
                    if(oDecoratedOLITemp.oOLI.MRC__c != null) oOLIAggregates.dSumMRCOME       += oDecoratedOLITemp.oOLI.MRC__c;
                    if(oDecoratedOLITemp.oOLI.Term_in_months__c != null){
                    if( oDecoratedOLITemp.oOLI.Term_in_months__c > oOLIAggregates.dMaxTermOME)  oOLIAggregates.dMaxTermOME = oDecoratedOLITemp.oOLI.Term_in_months__c;
                    }
                    if(oDecoratedOLITemp.oOLI.TotalPrice != null) oOLIAggregates.dSumTCVOME       += oDecoratedOLITemp.oOLI.TotalPrice;
                    if(oDecoratedOLITemp.oOLI.SMB_OPPPR_Net_Incremental_OV__c!= null)  oOLIAggregates.dSumTNIOVIntlOME += oDecoratedOLITemp.oOLI.SMB_OPPPR_Net_Incremental_OV__c;
                    if(oDecoratedOLITemp.oOLI.SMB_OPPPR_TCV_International__c!= null) oOLIAggregates.dSumTCVIntlFROME += oDecoratedOLITemp.oOLI.SMB_OPPPR_TCV_International__c;
                    if(oDecoratedOLITemp.oOLI.SMB_OPPR_CAS_NIOV__c!= null)oOLIAggregates.dSumDeltaCAFROME += oDecoratedOLITemp.oOLI.SMB_OPPR_CAS_NIOV__c;
                     System.debug('t6.4');
            }
           
                iTOT++;


               System.debug('t7'); 
                //aggregates (Opty level)
                if (oDecoratedOLITemp.oOLI.One_Off_Charge__c!=null)               oOLIAggregates.dSumOTCTOT       += oDecoratedOLITemp.oOLI.One_Off_Charge__c;
                if (oDecoratedOLITemp.oOLI.MRC__c!=null)                          oOLIAggregates.dSumMRCTOT       += oDecoratedOLITemp.oOLI.MRC__c;
                if( oDecoratedOLITemp.oOLI.Term_in_months__c > oOLIAggregates.dMaxTermTOT)  oOLIAggregates.dMaxTermTOT = oDecoratedOLITemp.oOLI.Term_in_months__c;
                if (oDecoratedOLITemp.oOLI.TotalPrice!=null)                      oOLIAggregates.dSumTCVTOT       += oDecoratedOLITemp.oOLI.TotalPrice;
                if (oDecoratedOLITemp.oOLI.SMB_OPPPR_Net_Incremental_OV__c!=null) oOLIAggregates.dSumTNIOVIntlTOT += oDecoratedOLITemp.oOLI.SMB_OPPPR_Net_Incremental_OV__c;
                if (oDecoratedOLITemp.oOLI.SMB_OPPPR_TCV_International__c!=null)  oOLIAggregates.dSumTCVIntlFRTOT += oDecoratedOLITemp.oOLI.SMB_OPPPR_TCV_International__c;
                if (oDecoratedOLITemp.oOLI.SMB_OPPR_CAS_NIOV__c!=null)            oOLIAggregates.dSumDeltaCAFRTOT += oDecoratedOLITemp.oOLI.SMB_OPPR_CAS_NIOV__c;


            } // end of loop on listOLIUndecorated
            
            }

            return mapSubDomainOLI;
        } //end of findOLI
    
    

        // create a new OLI in DB.
        private void CreateNewOLI(
             id         priceBooEntryId
            ,id         OpportunityId
            ,string     sKeepGetContext
            ,decimal    dUnitPrice
            ,string     sProductName
            ,string     sProductCode
            
            //,string     sOMEProductCategory
        )
        {
                // First we prepare a new OLI in memory
                OpportunityLineItem oNewOLI = instantiateNewOLI(
                     priceBooEntryId
                    ,OpportunityId
                    ,sKeepGetContext
                    ,dUnitPrice
                );
                
                //push to DB
                insert oNewOLI;
                                
        }

        // instantiate a OLI in memory
        // The returned OLI can be used for
        // db insert and/or decoration for displaying in page
        private OpportunityLineItem instantiateNewOLI (
             id      priceBooEntryId
            ,id      OpportunityId


            ,string  sKeepGetContext
            ,decimal dUnitPrice
        ) 
        {
            OpportunityLineItem  oNewOLI = new OpportunityLineItem(
                //Id                             = 


                 PriceBookEntryId                = priceBooEntryId
                ,OpportunityId                   = OpportunityId
                //,productCode                   = oOLIUndecorated.productCode  //not writeable, automatically denormalized
                ,SMB_OPPPR_Context__c            = sKeepGetContext
                ,One_Off_Charge__c               = 0
                ,Term_in_months__c               = 0
                ,MRC__c                          = 0
                ,SMB_OPPPR_Net_Incremental_OV__c = 0
                ,SMB_OPPPR_TCV_International__c  = 0
                ,SMB_OPPR_CAS_NIOV__c            = 0
                ,Quantity                        = 1
                //,TotalPrice                    = 0 //only one of UnitPrice or TotalPrice must be specified

                ,UnitPrice                       = dUnitPrice
                ,OME_OPPPR_Bookable__c                   = true
                ,OME_OPPPR_P_S_Status__c                 = 'Pending'
                ,OME_OPPPR_P_S_Probability__c           ='Id.Opp.%'
            );
            return oNewOLI;



        } 
        // Select operator and Bookable
        // on the basis of country
        
        public void changeOperator() {
                                integer iSelectedOLIIndex  = Integer.valueof(Apexpages.currentPage().getParameters().get('rowNumberOLI'));
                                system.debug('changeOperator:IN:');
                                OpportunityLineItem oOLITemp= listOLIOME.get(iSelectedOLIIndex).oOLI;  
                                if(oOLITemp.OME_OPPPR_P_S_Delivery_Country__c != null )
                                {
                                List<OperatorAndBookable_byContry__c> country = [SELECT Bookable__c,Operator__c FROM OperatorAndBookable_byContry__c where Country__c =: oOLITemp.OME_OPPPR_P_S_Delivery_Country__c ];
                               // OperatorAndBookable_byContry__c.getInstance(oOLITemp.OME_OPPPR_P_S_Delivery_Country__c);
                                system.debug('changeOperator:Before:'+oOLITemp);
                                oOLITemp.OME_OPPPR_Bookable__c= country[0].Bookable__c.equals('TRUE');
                                 oOLITemp.OME_OPPPR_Operators__c=country[0].Operator__c;

                                listOLIOME[iSelectedOLIIndex].oOLI= oOLITemp;
                                system.debug('changeOperator:After:'+oOLITemp);
                                }
                                       
                                }
         public void disableSuspension(){
                                integer iSelectedOLIIndex  = Integer.valueof(Apexpages.currentPage().getParameters().get('rowNumberOLI'));
                                system.debug('disableSuspension:IN:');
                                DecoratedOLI OLIOMETemp= listOLIOME.get(iSelectedOLIIndex);  
                                OLIOMETemp.bDisableSuspensionReason = false;
                                system.debug('disableSuspension:Before:'+OLIOMETemp);
                                if(OLIOMETemp.oOLI.OME_OPPPR_P_S_Status__c == 'Cust. Def.')
                                OLIOMETemp.bDisableSuspensionReason = true;
                                else
                                OLIOMETemp.bDisableSuspensionReason = false;
                                listOLIOME[iSelectedOLIIndex]= OLIOMETemp;
                                system.debug('disableSuspension:After:'+OLIOMETemp);
                                       
                                }

    
}