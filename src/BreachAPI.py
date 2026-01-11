import hashlib
import requests


class BreachAPIService:
  def check_pwned(self, password: str) -> bool:
        """Ελέγχει αν ο κωδικός έχει διαρρεύσει χωρίς να τον στείλει ολόκληρο."""        
        sha1_password = hashlib.sha1(password.encode('utf-8')).hexdigest().upper()
        prefix, suffix = sha1_password[:5], sha1_password[5:]
        
        try:
            url = f"https://api.pwnedpasswords.com/range/{prefix}"
            response = requests.get(url, timeout=2)
            if response.status_code != 200:
                return False
            
            # Ελέγχουμε αν το suffix υπάρχει στην απάντηση
            hashes = (line.split(':') for line in response.text.splitlines())
            for h, count in hashes:
                if h == suffix:
                    return True # Βρέθηκε σε διαρροή
            return False
        except:
            return False 