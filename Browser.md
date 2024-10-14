class Utils:
    args: Namespace

    def __init__(self, webdriver: WebDriver):
        self.webdriver = webdriver
        with contextlib.suppress(Exception):
            locale = pylocale.getdefaultlocale()[0]
            pylocale.setlocale(pylocale.LC_NUMERIC, locale)
        self.config = self.loadConfig()

    # Other methods...

    def waitUntilVisible(self, by: str, selector: str, timeToWait: float = 30) -> WebElement:
        return WebDriverWait(self.webdriver, timeToWait).until(
            expected_conditions.visibility_of_element_located((by, selector))
        )

    def isLoggedIn(self) -> bool:
        logging.info("Checking if user is logged in...")
        retries = 3
        for attempt in range(retries):
            try:
                self.webdriver.get("https://rewards.bing.com/Signin/")
                with contextlib.suppress(TimeoutException):
                    self.waitUntilVisible(By.CSS_SELECTOR, 'html[data-role-name="RewardsPortal"]', timeToWait=60)
                    logging.info("User is logged in.")
                    return True
                logging.info("User is not logged in.")
                return False
            except TimeoutException as e:
                logging.error(f"Timeout attempt {attempt+1}/{retries} failed: {str(e)}", exc_info=True)
                if attempt < retries - 1:
                    time.sleep(5)  # Small delay before retrying
        return False

    # Rest of your methods...
