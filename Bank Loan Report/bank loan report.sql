USE BANK_LOAN;

/*show all coloumns with datatype*/
SHOW COLUMNS FROM `BANK_LOAN_data` FROM `BANK_LOAN`;

/*show all table data*/
select * from BANK_LOAN_data;

/*Total Loan Applications*/
SELECT COUNT(id) AS Total_Applications FROM bank_loan_data;

/*Total Loan Applications for 12th month*/
SELECT COUNT(id) AS Total_Applications FROM bank_loan_data
WHERE issue_date like '%-12-%';

/* month on month percentage increaase in Total Loan Applications */
WITH MonthlyData AS (
    SELECT
        DATE_FORMAT(STR_TO_DATE(issue_date, '%d-%m-%Y'), '%Y-%m') AS month_year,
        COUNT(*) AS applications_count
    FROM
        BANK_LOAN_data
    GROUP BY
        month_year
    ORDER BY
        month_year
),
PercentageChange AS (
    SELECT
        month_year,
        applications_count,
        LAG(applications_count, 1) OVER (ORDER BY month_year) AS previous_month_count,
        CASE
            WHEN LAG(applications_count, 1) OVER (ORDER BY month_year) IS NOT NULL THEN
                (applications_count - LAG(applications_count, 1) OVER (ORDER BY month_year)) /
                LAG(applications_count, 1) OVER (ORDER BY month_year) * 100
            ELSE
                NULL
        END AS percentage_change
    FROM
        MonthlyData
)
SELECT
    month_year,
    applications_count,
    percentage_change
FROM
    PercentageChange;

/* month on month percentage increaase in Total Loan funded */
WITH MonthlyData AS (
    SELECT
        DATE_FORMAT(STR_TO_DATE(issue_date, '%d-%m-%Y'), '%Y-%m') AS month_year,
        sum(loan_amount) AS total_loan_funded
    FROM
        BANK_LOAN_data
    GROUP BY
        month_year
    ORDER BY
        month_year
),
PercentageChange AS (
    SELECT
        month_year,
        total_loan_funded,
        LAG(total_loan_funded, 1) OVER (ORDER BY month_year) AS previous_month_count,
        CASE
            WHEN LAG(total_loan_funded, 1) OVER (ORDER BY month_year) IS NOT NULL THEN
                (total_loan_funded - LAG(total_loan_funded, 1) OVER (ORDER BY month_year)) /
                LAG(total_loan_funded, 1) OVER (ORDER BY month_year) * 100
            ELSE
                NULL
        END AS percentage_change
    FROM
        MonthlyData
)
SELECT
    month_year,
    total_loan_funded,
    percentage_change
FROM
    PercentageChange;

/*month on month total funded amount*/
select DATE_FORMAT(STR_TO_DATE(issue_date, '%d-%m-%Y'), '%Y-%m') AS month_year, sum(loan_amount) as total_funded_Amount from BANK_LOAN_data
group by MONTH_YEAR 
order by month_year;

/*month on month total amount recevied and  total funded amount*/
select DATE_FORMAT(STR_TO_DATE(issue_date, '%d-%m-%Y'), '%Y-%m') AS month_year, sum(total_payment) as total_received_Amount ,
sum(loan_amount) as total_funded_Amount from BANK_LOAN_data
group by MONTH_YEAR 
order by month_year;

/*month on month average interest rate*/
select DATE_FORMAT(STR_TO_DATE(issue_date, '%d-%m-%Y'), '%Y-%m') AS month_year, round(avg(int_rate)*100,2) as average_interest_rate from bank_loan_data
group by MONTH_YEAR 
order by month_year;

/*total good loan percentage*/
select (count(case when loan_status='fully paid' or loan_status='current' then id end) *100)/count(id) as good_loan_percentage from bank_loan_data;

/*month on month good loan percentage*/
select DATE_FORMAT(STR_TO_DATE(issue_date, '%d-%m-%Y'), '%Y-%m') AS month_year,
(count(case when loan_status='fully paid' or loan_status='current' then id end) *100)/count(id) as good_loan_percentage from bank_loan_data
group by MONTH_YEAR 
order by month_year;

/*month on month good loan applications*/
select DATE_FORMAT(STR_TO_DATE(issue_date, '%d-%m-%Y'), '%Y-%m') AS month_year, 
count(id) as good_loan_applications  from bank_loan_data where loan_status='fully paid' or loan_status='current'
group by MONTH_YEAR 
order by month_year;

/*month on month good loan amount*/
select DATE_FORMAT(STR_TO_DATE(issue_date, '%d-%m-%Y'), '%Y-%m') AS month_year, 
sum(loan_amount) as good_loan_amount from bank_loan_data where loan_status='fully paid' or loan_status='current'
group by MONTH_YEAR 
order by month_year;

/*month on month good loan received*/
select DATE_FORMAT(STR_TO_DATE(issue_date, '%d-%m-%Y'), '%Y-%m') AS month_year, 
sum(total_payment) as good_loan_amount_received from bank_loan_data where loan_status='fully paid' or loan_status='current'
group by MONTH_YEAR 
order by month_year;

/*total Bad loan percentage*/
select (count(case when loan_status='charged off' then id end) *100)/count(id) as good_loan_percentage from bank_loan_data;

/*month on month Bad loan percentage*/
select DATE_FORMAT(STR_TO_DATE(issue_date, '%d-%m-%Y'), '%Y-%m') AS month_year,
(count(case when loan_status='charged off' then id end) *100)/count(id) as good_loan_percentage from bank_loan_data
group by MONTH_YEAR 
order by month_year;

/*month on month bad loan amount*/
select DATE_FORMAT(STR_TO_DATE(issue_date, '%d-%m-%Y'), '%Y-%m') AS month_year, 
sum(loan_amount) as bad_loan_amount from bank_loan_data where loan_status='charged off' 
group by MONTH_YEAR 
order by month_year;

/*month on month bad loan received*/
select DATE_FORMAT(STR_TO_DATE(issue_date, '%d-%m-%Y'), '%Y-%m') AS month_year, 
sum(total_payment) as bad_loan_amount_received from bank_loan_data where loan_status='charged off'
group by MONTH_YEAR 
order by month_year;

/*Bank loan status*/
SELECT loan_status, count(id) as total_application, sum(loan_amount) as amount_funded,
sum(total_payment) as amount_received, avg(int_rate) as average_interest_rate, avg(dti) as debt_to_income from bank_loan_data 
group by loan_status
order by loan_status;

/*Bank loan status for 12th month*/
SELECT loan_status, count(id) as total_application, sum(loan_amount) as amount_funded,
sum(total_payment) as amount_received, avg(int_rate) as average_interest_rate, avg(dti) as debt_to_income from bank_loan_data 
WHERE issue_date like '%-12-%'
group by loan_status
order by loan_status;

/*month by month bank loan report with month number and month name in asc order*/
select month(STR_TO_DATE(issue_date, '%d-%m-%Y')) as month_number, 
monthname(STR_TO_DATE(issue_date, '%d-%m-%Y')) as month_name, count(id) as application_count,
sum(loan_amount) as amount_funded,
sum(total_payment) as amount_received from bank_loan_data
group by month_number,month_name
order by month_number;

/*bank loan report by state arranged in alphabetical order */
select address_state, count(id) as application_count,
sum(loan_amount) as amount_funded,
sum(total_payment) as amount_received from bank_loan_data
group by address_state
order by address_state;

/*bank loan report by loan term*/
select term as loan_term, count(id) as application_count,
sum(loan_amount) as amount_funded,
sum(total_payment) as amount_received from bank_loan_data
group by term
order by term;

/*bank loan report by employement length */
select emp_length as employment_length, count(id) as application_count,
sum(loan_amount) as amount_funded,
sum(total_payment) as amount_received from bank_loan_data
group by emp_length
order by emp_length;

/*bank loan report by purpose*/
select PURPOSE as PURPOSE_OF_LOAN, count(id) as application_count,
sum(loan_amount) as amount_funded,
sum(total_payment) as amount_received from bank_loan_data
group by PURPOSE
order by purpose;

/*bank loan report by OWNERSHIP of Home*/
select home_ownership, count(id) as application_count,
sum(loan_amount) as amount_funded,
sum(total_payment) as amount_received from bank_loan_data
group by home_ownership
order by home_ownership;

/*bank loan report by OWNERSHIP of Home where grade is A*/
select home_ownership, count(id) as application_count,
sum(loan_amount) as amount_funded,
sum(total_payment) as amount_received from bank_loan_data
where grade='a'
group by home_ownership
order by home_ownership;

/*average interest rate where grade is A*/
select avg(int_rate)*100 as average_interest_rate from bank_loan_data
where grade='a';

/*average interest rate where grade is A*/
select grade, avg(int_rate)*100 as average_interest_rate from bank_loan_data
group by grade
order by grade;


