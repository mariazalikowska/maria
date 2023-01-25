@isTest
public class UpdateAccountAddressesBatchTest {
	@testSetup
	static void setup() {
		List<Account> accounts = new List<Account>();
		List<ResidentialLoanApplication> loanApplications = new List<ResidentialLoanApplication>();
		List<LoanApplicant> loanApplicants = new List<LoanApplicant>();
		List<LoanApplicantAddress> addresses = new List<LoanApplicantAddress>();

		Account account1 = new Account(
			FirstName = 'Hugo',
			LastName = 'Test1',
			BillingPostalCode = 'OLD POSTAL CODE 1',
			PreferredContactMethod__c = 'SMS'
		);
		accounts.add(account1);

		Account account2 = new Account(FirstName = 'Hugo', LastName = 'Test2', BillingPostalCode = 'OLD POSTAL CODE 2');
		accounts.add(account2);
		insert accounts;

		ResidentialLoanApplication application11 = new ResidentialLoanApplication(
			Name = 'Test Application',
			AccountId = account1.Id
		);
		loanApplications.add(application11);

		ResidentialLoanApplication application12 = new ResidentialLoanApplication(
			Name = 'Test Application',
			AccountId = account1.Id,
			Status = 'Cancelled'
		);
		loanApplications.add(application12);

		ResidentialLoanApplication application2 = new ResidentialLoanApplication(
			Name = 'Test Application',
			AccountId = account2.Id
		);
		loanApplications.add(application2);
		insert loanApplications;

		LoanApplicant applicant11 = new LoanApplicant(Name = 'Test Applicant', LoanApplicationId = application11.Id);
		loanApplicants.add(applicant11);

		LoanApplicant applicant12 = new LoanApplicant(Name = 'Test Applicant', LoanApplicationId = application12.Id);
		loanApplicants.add(applicant12);

		LoanApplicant applicant2 = new LoanApplicant(Name = 'Test Applicant', LoanApplicationId = application2.Id);
		loanApplicants.add(applicant2);
		insert loanApplicants;

		LoanApplicantAddress address111 = new LoanApplicantAddress(
			Name = 'Test address',
			LoanApplicantId = applicant11.Id,
			CurrentAddress__c = true,
			ResidencePostalCode = 'NEW POSTAL CODE 111'
		);
		addresses.add(address111);

		LoanApplicantAddress address112 = new LoanApplicantAddress(
			Name = 'Test address',
			LoanApplicantId = applicant11.Id,
			CurrentAddress__c = false,
			ResidencePostalCode = 'NEW POSTAL CODE 112'
		);
		addresses.add(address112);

		LoanApplicantAddress address121 = new LoanApplicantAddress(
			Name = 'Test address',
			LoanApplicantId = applicant12.Id,
			CurrentAddress__c = true,
			ResidencePostalCode = 'NEW POSTAL CODE 121'
		);
		addresses.add(address121);

		LoanApplicantAddress address2 = new LoanApplicantAddress(
			Name = 'Test address',
			LoanApplicantId = applicant2.Id,
			CurrentAddress__c = true,
			ResidencePostalCode = 'NEW POSTAL CODE 22'
		);
		addresses.add(address2);
		insert addresses;
	}

	@isTest
	static void test() {
		Test.startTest();
		UpdateAccountAddressesBatch myBatch = new UpdateAccountAddressesBatch();
		Database.executeBatch(myBatch);
		Test.stopTest();

		String postCode1 = [SELECT BillingPostalCode FROM Account WHERE LastName = 'Test1'].BillingPostalCode;
		String postCode2 = [SELECT BillingPostalCode FROM Account WHERE LastName = 'Test2'].BillingPostalCode;

		System.assertEquals('NEW POSTAL CODE 111', postCode1, 'No update of account record');
		System.assertEquals('OLD POSTAL CODE 2', postCode2, 'Wrong update of account record');
	}
}
