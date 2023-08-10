local cfg = {}

cfg.checkDuration = 30
cfg.minMoney = 5000

cfg.biz_types = {
	-- Gunshop-uri --
	['gunshopls'] = 'GUNSHOP LOS SANTOS',
	['gunshopsandy'] = 'GUNSHOP SANDY SHORES',
	['gunshoppaleto'] = 'GUNSHOP PALETO BAY',

	-- Service-uri --
	['servicesandy'] = 'SERVICE SANDY SHORES',
	['servicels'] = 'SERVICE LOS SANTOS',
	['servicepaleto'] = 'SERVICE PALETO BAY',
	['servicedusty'] = 'SERVICE HARMONY',
	
	-- Frizerii --
	['barbersandy'] = 'FRIZERIE SANDY SHORES',
	['barberpaleto'] = 'FRIZERIE PALETO BAY',
	['barberls'] = 'FRIZERIE LOS SANTOS',

	-- Cluburi --

	['vanilla'] = 'CLUB VANILLA UNICORN',
	['galaxy'] = 'CLUB GALAXY',
	['tequila'] = 'CLUB TEQUILA-LA',

	-- Baruri --
	['yellowjackin'] = 'BAR YELLOW JACK-IN',
	['barmirror'] = 'BAR MIRROR PARK',

}

cfg.biz_descriptions = {
	
	-- Gunshop-uri --
	['gunshopls'] = 'Fiecare magazin de muniție, arme albe și diverse își rezervă dreptul de a-și selecta clienții, dețînătorii au obligația de a alimenta magazinul cât de repede posibil când acesta rămâne fără stoc și totodată are dreptul de a-și angaja persoane care să se ocupe de vânzări. Magazinul are obligația atât de a avea actele in regulă și de a coopera cu autoritățile, cât și de a plăti taxa săptămânală aferentă acestei locații.',
	['gunshopsandy'] = 'Fiecare magazin de muniție, arme albe și diverse își rezervă dreptul de a-și selecta clienții, dețînătorii au obligația de a alimenta magazinul cât de repede posibil când acesta rămâne fără stoc și totodată are dreptul de a-și angaja persoane care să se ocupe de vânzări. Magazinul are obligația atât de a avea actele in regulă și de a coopera cu autoritățile, cât și de a plăti taxa săptămânală aferentă acestei locații.',
	['gunshoppaleto'] = 'Fiecare magazin de muniție, arme albe și diverse își rezervă dreptul de a-și selecta clienții, dețînătorii au obligația de a alimenta magazinul cât de repede posibil când acesta rămâne fără stoc și totodată are dreptul de a-și angaja persoane care să se ocupe de vânzări. Magazinul are obligația atât de a avea actele in regulă și de a coopera cu autoritățile, cât și de a plăti taxa săptămânală aferentă acestei locații.',

	-- Service-uri --
	['servicesandy'] = 'Fiecare service este obligat, prin lege, să plătească taxele aferente acestei locații săptămânal, pentru a evita închiderea temporară a acestuia, în fiecare service auto trebuie să existe angajați care să-i întâmpine și să se ocupe în permanentă de clienți. Proprietarii service-ului sunt rugați să se asigure de bună funcționare a acestuia, de ordine cât și de experiență clienților pe parcursul vizitei.',
	['servicels'] = 'Fiecare service este obligat, prin lege, să plătească taxele aferente acestei locații săptămânal, pentru a evita închiderea temporară a acestuia, în fiecare service auto trebuie să existe angajați care să-i întâmpine și să se ocupe în permanentă de clienți. Proprietarii service-ului sunt rugați să se asigure de bună funcționare a acestuia, de ordine cât și de experiență clienților pe parcursul vizitei.',
	['servicepaleto'] = 'Fiecare service este obligat, prin lege, să plătească taxele aferente acestei locații săptămânal, pentru a evita închiderea temporară a acestuia, în fiecare service auto trebuie să existe angajați care să-i întâmpine și să se ocupe în permanentă de clienți. Proprietarii service-ului sunt rugați să se asigure de bună funcționare a acestuia, de ordine cât și de experiență clienților pe parcursul vizitei.',
	['servicedusty'] = 'Fiecare service este obligat, prin lege, să plătească taxele aferente acestei locații săptămânal, pentru a evita închiderea temporară a acestuia, în fiecare service auto trebuie să existe angajați care să-i întâmpine și să se ocupe în permanentă de clienți. Proprietarii service-ului sunt rugați să se asigure de bună funcționare a acestuia, de ordine cât și de experiență clienților pe parcursul vizitei.',

	-- Frizerii --
	['barbersandy'] = 'Aceasta este o afacere prin care poti ajuta oamenii cu frizuri.',
	['barberpaleto'] = 'Aceasta este o afacere prin care poti ajuta oamenii cu frizuri.',
	['barberls'] = 'Aceasta este o afacere prin care poti ajuta oamenii cu frizuri.',

	-- Cluburi --
	['vanilla'] = 'Cluburile sunt menite să ofere un loc de relaxare tuturor persoanelor care simt că au nevoie de acest lucru, dețînătorii fiecărei locații sunt obligați să achite săptămânal o taxa de întreținere pentru a evita suspendarea activității clubului, totodată aceștia trebuie să-și angajeze persoane care să întrețină locația in fiecare zi, să mențină pacea și să asigure fiecare persoană din incinta clubului.',
	['galaxy'] = 'Cluburile sunt menite să ofere un loc de relaxare tuturor persoanelor care simt că au nevoie de acest lucru, dețînătorii fiecărei locații sunt obligați să achite săptămânal o taxa de întreținere pentru a evita suspendarea activității clubului, totodată aceștia trebuie să-și angajeze persoane care să întrețină locația in fiecare zi, să mențină pacea și să asigure fiecare persoană din incinta clubului.',
	['tequila'] = 'Cluburile sunt menite să ofere un loc de relaxare tuturor persoanelor care simt că au nevoie de acest lucru, dețînătorii fiecărei locații sunt obligați să achite săptămânal o taxa de întreținere pentru a evita suspendarea activității clubului, totodată aceștia trebuie să-și angajeze persoane care să întrețină locația in fiecare zi, să mențină pacea și să asigure fiecare persoană din incinta clubului.',

	-- Baruri --
	['yellowjackin'] = 'Barurile sunt menite să ofere un refugiu tuturor persoanelor care simt că au nevoie de acest lucru, dețînătorii fiecărei locații sunt obligați să achite săptămânal o taxa de întreținere pentru a evita suspendarea activității barului, totodată aceștia trebuie să-și angajeze persoane care să întrețînă locația in fiecare zi, să servească persoanele, să mențină pacea și să asigure fiecare persoană din incinta barului.',
	['barmirror'] = 'Barurile sunt menite să ofere un refugiu tuturor persoanelor care simt că au nevoie de acest lucru, dețînătorii fiecărei locații sunt obligați să achite săptămânal o taxa de întreținere pentru a evita suspendarea activității barului, totodată aceștia trebuie să-și angajeze persoane care să întrețînă locația in fiecare zi, să servească persoanele, să mențină pacea și să asigure fiecare persoană din incinta barului.',
}

return cfg