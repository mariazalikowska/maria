public class UpdateAccountAddressesBatch implements Database.Batchable<sObject>, Database.Stateful {
	public Integer recordsProcessed = 0;
	Set<Id> updatedAccounts = new Set<Id>();
	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(
			'SELECT ID, ResidenceCity, LoanApplicant.LoanApplication.Account.BillingCity, ' +
			'ResidenceCountry, LoanApplicant.LoanApplication.Account.BillingCountry, ' +
			'ResidenceGeocodeAccuracy, LoanApplicant.LoanApplication.Account.BillingGeocodeAccuracy, ' +
			'ResidenceLatitude, LoanApplicant.LoanApplication.Account.BillingLatitude, ' +
			'ResidenceLongitude, LoanApplicant.LoanApplication.Account.BillingLongitude, ' +
			'ResidencePostalCode, LoanApplicant.LoanApplication.Account.BillingPostalCode, ' +
			'ResidenceState, LoanApplicant.LoanApplication.Account.BillingState, ' +
			'ResidenceStreet, LoanApplicant.LoanApplication.Account.BillingStreet ' +
			'FROM LoanApplicantAddress ' +
			'WHERE CurrentAddress__c = true ' +
			'AND LoanApplicant.LoanApplication.Status !=\'Cancelled\' ' +
			'AND LoanApplicant.LoanApplication.Status !=\'Declined\' ' +
			'AND LoanApplicant.LoanApplication.Account.PreferredContactMethod__c != \'\''
		);
	}

	public void execute(Database.BatchableContext bc, List<LoanApplicantAddress> records) {
		List<Account> accounts = new List<Account>();
		Map<Id, Account> accountsMap = new Map<Id, Account>();

		for (LoanApplicantAddress address : records) {
			Account acc = new Account(
				Id = address.LoanApplicant.LoanApplication.Account.Id,
				BillingCity = address.ResidenceCity,
				BillingCountry = address.ResidenceCountry,
				BillingGeocodeAccuracy = address.ResidenceGeocodeAccuracy,
				BillingLatitude = address.ResidenceLatitude,
				BillingLongitude = address.ResidenceLongitude,
				BillingPostalCode = address.ResidencePostalCode,
				BillingState = address.ResidenceState,
				BillingStreet = address.ResidenceStreet
			);

			accountsMap.put(address.LoanApplicant.LoanApplication.Account.Id, acc);
		}

		for (Id accId : accountsMap.keySet()) {
			accounts.add(accountsMap.get(accId));
			recordsProcessed = recordsProcessed + 1;
		}
		updatedAccounts = accountsMap.keySet();
		update accounts;
	}
	public void finish(Database.BatchableContext bc) {
		AsyncApexJob job = [
			SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
			FROM AsyncApexJob
			WHERE Id = :bc.getJobId()
		];
		Logger.info('Batch job: ' + job);
		Logger.info('recordsProcessed: ' + recordsProcessed);
		Logger.info('updatedAccounts: ' + updatedAccounts);
	}
}
