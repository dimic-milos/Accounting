# Accounting
Accounting aplication made for companies dealing with farmers. App tracks financial status of each farmer based on the farmer grain production, his purchases, cooperation contracts signed for seed, fertilizer, short-term cash allowances or other needs. Calculations are beeing made using EURO or DOLLAR currency tracking

# ADDING A NEW CLIENT

User inputs new client data into eight fields. Every piece of data is being checked against required conditions:
<a href="https://imgflip.com/gif/1tj2g2"><img src="https://i.imgflip.com/1tj2g2.gif" title="made at imgflip.com"/></a>

# CHANGE CLIENT DATA

If necessary user can edit previously recorded data by selecting appropriate field:
<a href="https://imgflip.com/gif/1tj2hk"><img src="https://i.imgflip.com/1tj2hk.gif" title="made at imgflip.com"/></a>

# GOODS DELIVERED

CORN IN

Farmer brings four loads of corn. Quality parameters (humidity, purity) is being recorded where data is provided and calcultated in if it steps out of standard for selected goods (corn, wheat, sunflower):
<a href="https://imgflip.com/gif/1tj2cg"><img src="https://i.imgflip.com/1tj2cg.gif" title="made at imgflip.com"/></a>

Farmer brings one load of corn. Quality parameters (humidity, purity) not recorded because data is not provided. All inputs are checked for non logical data inpouts. Warning is presented if data cheks out to be faulty:
<a href="https://imgflip.com/gif/1tj2ry"><img src="https://i.imgflip.com/1tj2ry.gif" title="made at imgflip.com"/></a>

WEATH IN

Farmer brings two loads of weath. Quality parameters (humidity, purity) is being recorded where data is provided and calcultated in if it steps out of standard for selected goods (corn, wheat, sunflower):
<a href="https://imgflip.com/gif/1tj2mb"><img src="https://i.imgflip.com/1tj2mb.gif" title="made at imgflip.com"/></a>

# EXCHANGE RATE

User is promted to provide selling/middle/buying exchange rate for Euro and Dollar. App checks if the exchange rate has been already saved for the particular date. If not, it checks user input for non logical data; example: selling exchange rate set to be lower than buying exchange rate. Warning presented if data needs to altered:
<a href="https://imgflip.com/gif/1tj2wq"><img src="https://i.imgflip.com/1tj2wq.gif" title="made at imgflip.com"/></a>

# ARTICLES

User is promted to provide information about the smallest package available for selling. Required fields are Name, Origin,  Weight. Packaging description is a required input thru segmented control to avoid common mistakes. All fields are required in order to provide the user freedom to later inputs selling/buying quantities either using KG or PIECES. 
<a href="https://imgflip.com/gif/1tj32i"><img src="https://i.imgflip.com/1tj32i.gif" title="made at imgflip.com"/></a>

# CONTRACTS

**NEW CONTRACT FOR ARTICLE 1:
Fertilizer brand name UREA

Farmer needs fertilizers, or seed for his field so he decides to make a contract to finance his purchase. Contract states that he will sell his production to the company in order to clear his debt.

Making a new contract with the farmer is easy. User selects previously entered article from the picker, enters the quantity and packiging. User selects goods in which the farmer pays out his depbt and date picker automatically sets to predefined date. This date can also be manually altered. Exchange rate is saved for the currency selected in order to calculate further value of the contract.

If the contract is in domestic currency, exchanger rate is not being calculated in, it can be turned off by moving the switch to off position. Farmer has to clear his debt on time, otherwise interest on his unpaid portion of the contract value is being calculated in. This is optional so there is another switch to turn off this option.

If the contract is in domestic currency, exchanger rate is not being calculated in, it can be turned off by moving the switch to off position. Farmer has to clear his debt on time, otherwise interest on his unpaid portion of the contract value is being calculated in. This is optional so there is another switch to turn off this option.

Farmer has to provide guarantees paperwork. Number of guarantee is being recorded also. All inputs are checked:
<a href="https://imgflip.com/gif/1tj3a9"><img src="https://i.imgflip.com/1tj3a9.gif" title="made at imgflip.com"/></a>

**CONTRACT FOR ARTICLE 1 GOODS PULLED FROM THE WAREHOUSE
Fertilizer brand name UREA

When the contract is signed farmer can pick up goods needed. User types farmers name, table with all contracts associated with that farmer is populated. Table show details of each contract, most importantly shows how much more of the goods can be taken off the current contract. Every time goods are being taken off the contract, app check if it is under signed quantities.

<a href="https://imgflip.com/gif/1tj3it"><img src="https://i.imgflip.com/1tj3it.gif" title="made at imgflip.com"/></a>

**NEW CONTRACT FOR ARTICLE 2 :
Fertilizer brand name NPK

User input mistakes are minimal because user input is limited and checked. If the contract value exceeds predefined value an alaert is shown:

<a href="https://imgflip.com/gif/1tj3p8"><img src="https://i.imgflip.com/1tj3p8.gif" title="made at imgflip.com"/></a>

**CONTRACT FOR ARTICLE 2 GOODS PULLED FROM THE WAREHOUSE
Fertilizer brand name NPK

Farmers name is being inputed and appropriate articles are being selected. User also provides details about the quantity and packaging of the goods given to the farmer. Data is check for inconsistencies:
<a href="https://imgflip.com/gif/1tj3v4"><img src="https://i.imgflip.com/1tj3v4.gif" title="made at imgflip.com"/></a>

# FINANCIAL JUST TWO CONTRACTS

User can see financial status of each farmer. Every cell shows details about the particular contract and it's starting value, interest accumulated and exchange rate changes calculated and presented separately. Also user can see financial status and value of each farmers debt based on date when contracts expire or financial status altogether for more broader view of financials.

<a href="https://imgflip.com/gif/1tj3zs"><img src="https://i.imgflip.com/1tj3zs.gif" title="made at imgflip.com"/></a>

# PAYING MONEY FOR GOODS PARTLY
Whenever goods are being paid to the farmer, payment consist of two separate parts, TAX + REST. This app takes care of tracking and signaling if TAX part is not paid since it is required by law for TAX part to be paid to the farmer even if the farmer owns money to the company. Activity indicator show the progress of each payment:

<a href="https://imgflip.com/gif/1tj475"><img src="https://i.imgflip.com/1tj475.gif" title="made at imgflip.com"/></a>

# PAYING MONEY FOR GOODS THE REST
User inputs how much money is paid to the farmer, selects the bank, date and the number of invoice and the app cross-reference data in order to clear debt and paints the TAX and the REST fields in green indicating everything has been cleared.

<a href="https://imgflip.com/gif/1tj4c7"><img src="https://i.imgflip.com/1tj4c7.gif" title="made at imgflip.com"/></a>

# BUYING GOODS WITH TWO CONTRACTS CLEARED
Farmer comes to the administration office to get his invoice. User selects goods to be calculated in (all based on previous  goods deliveries inputs). List of inputs is colored in red and green indicating if those deliveries. User inputs the price of goods being bought and selects contracts to be substracted from this purchase. Value of each contract can be adjusted using sliders. Tax part is being calculated separately in order to be paid separately. Compensation paper is being generated and printed. Exchange rate calculation paper is being generated and printed. Compansation paper and exchange rate paper connect this particular inovice. This inovice is connected to particular goods delivery input. Financial status of the farmer is altered:

<a href="https://imgflip.com/gif/1tj4k8"><img src="https://i.imgflip.com/1tj4k8.gif" title="made at imgflip.com"/></a>

# PAYING MONEY FOR TAX MUST PART AND THE REST TO CLEAR

<a href="https://imgflip.com/gif/1tj4qt"><img src="https://i.imgflip.com/1tj4qt.gif" title="made at imgflip.com"/></a>

# BUYING GOODS NO CONTRACT
Farmer can sell his goods and get the full amount paid even if he has open contracts. User is able to go around open contracts and pay the full amount to the farmer.

<a href="https://imgflip.com/gif/1tj4wt"><img src="https://i.imgflip.com/1tj4wt.gif" title="made at imgflip.com"/></a>

# ADVANCE PAYMENT
Sometimes a farmer needs some cash in advance. User can input this type of change into app and clear them later when the farmer delivers goods:

<a href="https://imgflip.com/gif/1tj52e"><img src="https://i.imgflip.com/1tj52e.gif" title="made at imgflip.com"/></a>

# ADVANCE PAYMENT CLEARED WITH BUYING GOODS AND TAX MUST PART PAID
When clearing advance payment, farmer delivers goods to the company. User creates invoice, select the advance payment to be cleared, uses the slider to adjust the value. Note that slider cannot exceed the value of goods without tax and it levels to the hundreds part of contract value. App calculates necessary paperwork and updates financial status of the farmer.

<a href="https://imgflip.com/gif/1tj59b"><img src="https://i.imgflip.com/1tj59b.gif" title="made at imgflip.com"/></a>

# SEARCH CLIENT DIFFERENT CRITERIUMS
User can search through database using name or personal number of the farmer

<a href="https://imgflip.com/gif/1tj5cs"><img src="https://i.imgflip.com/1tj5cs.gif" title="made at imgflip.com"/></a>
