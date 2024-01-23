package SeleniumGroup.SeleniumArtifact;


import org.testng.annotations.Test;

public class TestCases extends BeforeAndAfterClass{

	@Test (priority=0)
	public void doInstallAA() throws Exception
	{
		InstallationPage install = new InstallationPage(driver, inputs.getProperty("UrlOfAA"), inputs.getProperty("AdminUserPassword"));
		install.doInstallAA();
		Thread.sleep(5 * 60 * 1000); //Wait for 5 minutes after AA Installation
	}
	@Test (dependsOnMethods={"doInstallAA"})
	public void doAdminLogin() 
	{
		SignInPage signInPage = new SignInPage(driver, inputs.getProperty("AdminUserName"),inputs.getProperty("AdminUserPassword"));
		signInPage.adminLogin();
	}
	
}



/*	
	@Test (dependsOnMethods={"doAdminLogin", ""}, ignoreMissingDependencies=true)
	//@Test (dependsOnMethods={"doAdminLogin"})
	public void doAssignFullAdminRole()
	{
		RepositoryPage repositoryPage = new RepositoryPage(driver, inputs.getProperty("LDAPAdminGroup"));
		repositoryPage.assignFullAdminRole();
	}
}

// usually run will go like 0,1,2 priority order
// when priority is not specified TestNG assigns its priority=0 and in alphabetical order



@Test(priority=1)
public void test1() { }

@Test(priority=0)
public void test2() { }

@Test()
public void test3() { }

So will run like 2,3,1

*/