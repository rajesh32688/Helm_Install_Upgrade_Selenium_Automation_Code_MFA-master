package SeleniumGroup.SeleniumArtifact;


import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.lang.reflect.Method;
import java.time.Duration;
import java.util.Properties;

import org.junit.AfterClass;

//import org.junit.ClassRule;
//import org.junit.rules.TestName;

import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.UnexpectedAlertBehaviour;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.io.FileHandler;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.AfterSuite;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.BeforeSuite;

public class BeforeAndAfterClass {
	
	public static ChromeOptions options;
	public static WebDriver driver;
	public static WebDriver driver1;
	public static Properties inputs;
	public static FileInputStream inputFile;	
	
	String TestName="";
//	@ClassRule public static TestName name = new TestName();
	
	@BeforeSuite 
	public static void beforeMethod ()
	{
		inputs = new Properties();
		try {
			//inputFile = new FileInputStream(System.getProperty("user.dir")+"\\application.properties");
			inputFile = new FileInputStream("/var/lib/jenkins/workspace/Helm_Install_Upgrade_With_Seleium_Automation/application.properties");
			inputs.load(inputFile);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}									
	    
	    
		options = new ChromeOptions();
		options.setAcceptInsecureCerts(true);
    	options.setUnhandledPromptBehaviour(UnexpectedAlertBehaviour.ACCEPT);
    	
    	
    	options.addArguments("--no-sandbox");
    	options.addArguments("--headless"); //!!!should be enabled for Jenkins
    	options.addArguments("--disable-dev-shm-usage"); //!!!should be enabled for Jenkins
    	options.addArguments("--window-size=1920x1080"); //!!!should be enabled for Jenkins
   
    	
    	
        driver = new ChromeDriver(options);
        //driver.manage().timeouts().implicitlyWait(60, TimeUnit.SECONDS); //Deprecated
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(120));
        driver.manage().window().maximize();
        driver.get("https://"+inputs.getProperty("UrlOfAA"));
        System.out.println("https://"+inputs.getProperty("UrlOfAA"));
//        driver1 = new FirefoxDriver();
 //       driver1.get(inputs.getProperty("UrlOfAA"));
    }
	@BeforeMethod
	   public void name(Method method) {
	      TestName=method.getName();
	      System.out.println(method.getName());
	   }
	@BeforeMethod
	   public void Summa() {
	      System.out.println("Summa to prove multiple @BeforeMethod annotation");
	   }
	@BeforeClass
	//Empty
	@AfterClass
	//Empty

//	@AfterMethod (alwaysRun=true)
//	public void afterMethod ()
//	{
//		  // name.getMethodName(); --> For Junit @RULE
//		  File file = new File(System.getProperty("user.dir")+"\\target\\ScreenShots\\Screen_Shot_Of_"+TestName.toUpperCase()+".jpg");
//	      //TakesScreenshot scrShot =((TakesScreenshot) driver);
//	      File shot=((TakesScreenshot) driver).getScreenshotAs(OutputType.FILE);
//	      	try {	FileHandler.copy(shot, file);	}
//	      	catch (IOException e) {	e.printStackTrace();	}
//	}
	
	@AfterSuite
	public void afterSuite ()
	{
	//	driver.quit();
	}
}
