import hashlib
import requests

class BreachAPIService:
    def get_breach_count(self, password: str) -> int:
        """
        Ελέγχει τον κωδικό και επιστρέφει τον ΑΡΙΘΜΟ των διαρροών (Count).
        Επιστρέφει 0 αν ο κωδικός είναι ασφαλής ή -1 αν υπάρξει σφάλμα δικτύου.
        """        
        # 1. SHA-1 Hash (όπως ακριβώς το είχες)
        sha1_password = hashlib.sha1(password.encode('utf-8')).hexdigest().upper()
        prefix, suffix = sha1_password[:5], sha1_password[5:]
        
        try:
            # 2. Κλήση στο API (k-anonymity)
            url = f"https://api.pwnedpasswords.com/range/{prefix}"
            response = requests.get(url, timeout=2) # Timeout error
            
            if response.status_code != 200:
                print(f"BreachAPI Error: {response.status_code}")
                return 0
            
            # 3. Parsing της απάντησης
            hashes = (line.split(':') for line in response.text.splitlines())
            
            for h, count in hashes:
                if h == suffix:
                    # ΒΡΕΘΗΚΕ! Επιστρέφουμε το count ως ακέραιο
                    return int(count)
            
            # Αν τελειώσει η λούπα και δεν το βρούμε, είναι ασφαλές
            return 0

        except requests.exceptions.Timeout:
            print("BreachAPI: Timeout reached.")
            return -1
        except Exception as e:
            print(f"BreachAPI Error: {e}")
            return -1