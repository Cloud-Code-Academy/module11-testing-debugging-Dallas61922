@isTest
public with sharing class LeadTest {

    @isTest
    public static void testLeadTriggerHandler_handleTitleNormalization() {//Seems to work well
        List<Lead> leadsToNormalize = new List<Lead>();
        Lead lead1 = new Lead(FirstName = 'Bob', LastName = 'Smith', Title = 'mgr', Company = 'Test Co');
        Lead lead2 = new Lead(FirstName = 'Joe', LastName = 'Cross', Title = 'vp', Company = 'Test Co');
        Lead lead3 = new Lead(FirstName = 'Betty', LastName = 'Roberts', Title = 'assist', Company = 'Test Co');
        Lead lead4 = new Lead(FirstName = 'Jim', LastName = 'Bailey', Title = 'exec', Company = 'Test Co');
        leadsToNormalize.add(lead1);
        leadsToNormalize.add(lead2);
        leadsToNormalize.add(lead3);
        leadsToNormalize.add(lead4);
        insert leadsToNormalize;
        
        Lead updatedLead1 = [SELECT Title FROM Lead WHERE Id = :lead1.Id];
        Lead updatedLead2 = [SELECT Title FROM Lead WHERE Id = :lead2.Id];
        Lead updatedLead3 = [SELECT Title FROM Lead WHERE Id = :lead3.Id];
        Lead updatedLead4 = [SELECT Title FROM Lead WHERE Id = :lead4.Id];
        
        Assert.areEqual('Manager', updatedlead1.title, 'Lead title was not updated properly');
        Assert.areEqual('Vice President', updatedlead2.title, 'Lead title was not updated properly');
        Assert.areEqual('Assistant', updatedlead3.title, 'Lead title was not updated properly');
        Assert.areEqual('Executive', updatedlead4.title, 'Lead title was not updated properly');
    }

    @isTest
    public static void testLeadTriggerHandler_handleAutoLeadScoring(){//works
        List<Lead> scoredLeads = new List<Lead>();
        Lead lead1 = new Lead(FirstName = 'Bob', LastName = 'Smith', LeadSource = 'Web', Company = 'Test Co', Email = 'test@testing.com', Phone = '555-555-5555');
        Lead lead2 = new Lead(FirstName = 'Joe', LastName = 'Cross', Industry = 'Technology', Company = 'Test Co', Phone = '333-333-3333');
        Lead lead3 = new Lead(FirstName = 'Betty', LastName = 'Roberts', LeadSource = 'Other', Company = 'Test Co', Email = 'betty@boop.com');
        Lead lead4 = new Lead(FirstName = 'Jim', LastName = 'Bailey', Title = 'exec', Company = 'Test Co');
        scoredLeads.add(lead1);
        scoredLeads.add(lead2);
        scoredLeads.add(lead3);
        scoredLeads.add(lead4);

        Test.startTest();
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Database.insert(scoredLeads, dml);
        System.debug('Test = New lead1 id is ' + lead1.Id);
        Test.stopTest();
        
        Lead updatedLead1 = [SELECT Name, Id, Lead_Score__c FROM Lead WHERE Id = :lead1.Id];
        Lead updatedLead2 = [SELECT Name, Id, Lead_Score__c FROM Lead WHERE Id = :lead2.Id];
        Lead updatedLead3 = [SELECT Name, Id, Lead_Score__c FROM Lead WHERE Id = :lead3.Id];
        Lead updatedLead4 = [SELECT Name, Id, Lead_Score__c FROM Lead WHERE Id = :lead4.Id];

        Assert.areEqual (8, updatedLead1.Lead_score__c, 'Lead score is not calculated properly');
        Assert.areEqual(15, updatedLead2.Lead_score__c, 'Lead score is not calculated properly');
        Assert.areEqual(0, updatedLead3.Lead_score__c, 'Lead score is not calculated properly');
        Assert.areEqual(0, updatedLead4.Lead_score__c, 'Lead score is not calculated properly');

        lead4.industry = 'Technology';
        update lead4;
        Lead updatedLead = [SELECT Lead_Score__c FROM Lead WHERE Id = :lead4.Id];
        Assert.areEqual (10, updatedLead.Lead_Score__c, 'Lead score is not calculated properly');
    }

    @isTest
    public static void testLeadTriggerHandler_handleLeadAutoConvert(){
        Account testAccount = new Account(Name = 'Test');
        Insert testAccount;

        List<Contact> existingContacts = new List<Contact>();
        Contact con1 = new Contact(FirstName = 'Bob', LastName = 'Smith', Email = 'bob@testco.com', AccountId = testAccount.Id);
        existingContacts.add(con1);

        List<Lead> convertLeads = new List<Lead>();
        Lead lead1 = new Lead(FirstName = 'Bob', LastName = 'Smith', LeadSource = 'Web', Company = 'Test Co', Phone = '555-555-5555');
        Lead lead2 = new Lead(FirstName = 'Joe', LastName = 'Cross', Industry = 'Technology', Company = 'Test Co', Phone = '333-333-3333');
        Lead lead3 = new Lead(FirstName = 'Betty', LastName = 'Roberts', LeadSource = 'Other', Company = 'Test Co', Email = 'betty@boop.com');

        convertLeads.add(lead1);
        convertLeads.add(lead2);
        convertLeads.add(lead3);
        
        Test.startTest();
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Database.insert(existingContacts, dml);
        Database.insert(convertLeads, dml);
        lead1.Email='bob@testco.com';
        Database.update(lead1, dml);
        Test.stopTest();
        
        Lead updatedLead1 = [SELECT Id, IsConverted FROM Lead WHERE Id = :lead1.Id];
        Lead updatedLead2 = [SELECT Id, IsConverted FROM Lead WHERE Id = :lead2.Id];
        Lead updatedLead3 = [SELECT Id, IsConverted FROM Lead WHERE Id = :lead3.Id];

        Assert.isTrue(updatedLead1.IsConverted, 'Lead should have been converted but was not');
        Assert.isFalse(updatedLead2.IsConverted, 'Lead should not have been converted but was');
        Assert.isFalse(updatedLead3.IsConverted, 'Lead should not have been converted but was');
       
    }
}

