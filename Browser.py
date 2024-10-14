def isLoggedIn(self) -> bool:
    logging.info("Checking if user is logged in...")
    max_retries = 3
    for attempt in range(max_retries):
        try:
            self.webdriver.set_page_load_timeout(60)  # Set a timeout for page load
            self.webdriver.get("https://rewards.bing.com/Signin/")
            with contextlib.suppress(TimeoutException):
                self.waitUntilVisible(By.CSS_SELECTOR, 'html[data-role-name="RewardsPortal"]')
                logging.info("User is logged in.")
                return True
        except TimeoutException as e:
            logging.error(f"Attempt {attempt + 1}: TimeoutException: {str(e)}")
            if attempt + 1 < max_retries:
                logging.info("Retrying...")
                time.sleep(2 ** attempt)  # Exponential backoff
            else:
                logging.error("Failed to load the page after several attempts.")
                break
    logging.info("User is not logged in.")
    return False
