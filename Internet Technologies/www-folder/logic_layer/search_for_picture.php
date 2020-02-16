<?php
	// Mέθοδος που επιστρέφει έναν πίνακα με το αποτέλεσμα της αναζήτησης με βάση τις ετικέτες.
	function search_terms($terms) {
		// Ο διαχωρισμός των όρων γίνεται με το κόμμα.
		$strToken = strtok($terms, ",");
		$_SESSION['num_of_tokens'] = 0;
		// Για κάθε όρο αναζητούμε φωτογραφία που σχετίζεται με αυτόν.
		while($strToken){
			$_SESSION['num_of_tokens']++;
			// Γίνεται η αναζήτηση με βάση τις ετικέτες.
			$result = search_on_tags($strToken);
			$numrow = mysql_num_rows($result);
			// Η αναζήτηση γίνεται με την λειτουργία του λογικού AND, πρέπει δλδ  η φωτογραφία, να περιέχει όλους όρους
			// στο πεδία με τις ετικέτες, έτσι έστω και ένας να μην υπάρχει τότε δεν επιστρέφουμε αποτέλεσμα.
			if($numrow == 0){
				header("Location: search.php?not_found=2");
				exit();
			}
			// Γίνεται η αποθήκευση των id  των φωτογραφιών στον πίνακα ar.
			while ($row = mysql_fetch_array($result, MYSQL_ASSOC)){
				$ar[] = $row['picture_id'];					
			}			
			$strToken = strtok(",");
		}		
		// Επιστρέφουμε τον πίνακα με τα αποτελέσματα.
		return $ar;
	}
	// Μέθοδος που επιστρέφει έναν πίνακα με το αποτέλεσμα της αναζήτησης που έγινε σε όλα τα πεδία.
	function search_all ($terms) {
		// Ο διαχωρισμός των όρων γίνεται με το κόμμα.
		$strToken = strtok($terms, ",");
		$_SESSION['num_of_tokens'] = 0;
		// Για κάθε όρο αναζητούμε φωτογραφία που σχετίζεται με αυτόν.
		while($strToken){
			$_SESSION['num_of_tokens']++;
			// Γίνεται η αναζήτηση σε όλα τα πεδία.
			$result = search_on_everyfield($strToken);
			$numrow = mysql_num_rows($result);
			// Η αναζήτηση γίνεται με την λειτουργία του λογικού AND, πρέπει δλδ η φωτογραφία να περιέχει
			// όλους τους όρους  σε κάποιο από τα πεδία, έτσι έστω και ένας να μην υπάρχει τότε δεν επιστρέφουμε αποτέλεσμα.
			if($numrow==0){
				header("Location: search.php?not_found=1");
				exit();
			}
			// Γίνεται η αποθήκευση των id των φωτογραφιών στον πίνακα ar. 
			while ($row = mysql_fetch_array($result, MYSQL_ASSOC)){
				$ar[] = $row['pic_id'];
			}				
			$strToken = strtok(",");
		}		
		// Επιστρέφουμε τον πίνακα.
		return $ar;
	}
	// Μέθοδος που διαχωρίζει τις φωτογραφίες που περιέχουν όλους τους όρους αναζήτησης.
	function found_pictures($ar) {
			// Ο πίνακας ar περιέχει τα id των φωτογραφιών που περιέχουν κάποιο απο τους όρους αναζήτησης.
			// Εμείς όμως θέλουμε τις φωτογραφίες αυτές που περιέχουν όλους τους όρους αναζήτησης σε κάποιο πεδίο.
			// Έτσι έστω ότι έχουμε 2 όρους αναζήτησης. Μια φωτογραφία για να περιέχει και τους 2 όρους,
			// θα πρέπει το id της στον πίνακα ar να περιέχεται 2 φορές. 
			// Έτσι παρακάτω όταν ένα id βρίσκει των εαυτό του μέσα στον πίνακα αυξάνει έναν προσωρινό μετρητή κατά 1.
			// Όταν τελείωσει ο έλεγχος του πρώτου στοιχείου του ar ελέγχεται αν ο μετρητής είναι ίσος με τον αριθμό των όρων αναζήτησης.
			// Αν ναι, τότε τον κρατάμε σε έναν άλλο προσωρινό πίνακα. Αυτό συνεχίζεται για όλα τα στοιχεία του πίνακα ar. 
			foreach($ar as $val){
				$eq=0;
				
				foreach($ar as $val2){
					if($val==$val2) {
						$eq++;
					}					
					if($eq == $_SESSION['num_of_tokens']){
						$res[]=$val;				
					}
				}
			}
			// Αν όχι τότε επίστρεφουμε χωρίς αποτέλεσμα.
			if(!isset($res)){
				header("Location: search.php?not_found=1");
				exit();
			}
			// Αφαιρούμε τα διπλότυπα απο τον προσωρινό πίνακα res καθώς τα επιθυμητά στοιχεία θα βρεθούνε τουλάχιστον 2 φορές.
			$ar = array_unique($res);
			unset($_SESSION['num_of_tokens']);
			// Επιστρέφουμε τον πίνακα με τα id των φωτογραφιών που θέλουμε.
			return count($ar);
	}
?>		