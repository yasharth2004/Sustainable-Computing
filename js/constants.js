export const STORAGE_KEY='circular-campus-v1';
export const CATEGORIES=['Academic Books','Electronics','Stationery','Sports Equipment','Clothing','Dorm Essentials','Lab Equipment','Miscellaneous'];
export const TYPES=['Borrow','Share','Donate'];
export const CONDITIONS=['Brand New','Like New','Good','Usable'];
export const LOCATIONS=['Central Library','Innovation Lab','Main Hostel','Sports Complex','Admin Block','North Campus','Student Centre'];
export const uid=(prefix='id')=>`${prefix}-${Date.now().toString(36)}-${Math.random().toString(36).slice(2,7)}`;
export const dateLabel=value=>new Date(value).toLocaleDateString('en-IN',{day:'numeric',month:'short',year:'numeric'});
export const dateTimeLabel=value=>new Date(value).toLocaleString('en-IN',{day:'numeric',month:'short',hour:'numeric',minute:'2-digit'});
