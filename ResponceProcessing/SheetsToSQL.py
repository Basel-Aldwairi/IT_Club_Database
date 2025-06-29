import gspread
from oauth2client.service_account import ServiceAccountCredentials
import mysql.connector

scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
creds = ServiceAccountCredentials.from_json_keyfile_name("abiding-cistern-464415-d0-fa91a9de59d8.json", scope)
client  =gspread.authorize(creds)

sheet = client.open('Registration Responses').sheet1
data =sheet.get_all_records()

db = mysql.connector.connect(
    host='127.0.0.1',
    port='3306',
    user='root',
    password='1234',
    database='IT_Club'
)

cursor = db.cursor()

def null_prevention(raw_answer:str) -> str:
    if not raw_answer.strip() == '':
        return ''.join(['\'', raw_answer, '\''])
    else:
        return 'NULL'

cursor.execute('SELECT student_id FROM students')

existing_student_ids = set(row[0] for row in cursor.fetchall())

for row in data:
    uni_id = int(row['University ID'])
    if uni_id in existing_student_ids:
        continue

    first_name = null_prevention(row['First Name'])
    last_name = null_prevention(row['Last Name'])
    email = null_prevention(row['Email'])
    major_str = row['Major']
    major = 'X'
    remarks = ''

    if major_str == 'Computer Science':
        major = 'CS'
    elif major_str == 'Computer Engineering':
        major = 'CE'
    elif major_str == 'Electrical Engineering':
        major = 'EE'
    else:
        remarks = ''.join([remarks,'\nMajor is ',major_str])
    major = null_prevention(major)

    major_track_str = row['Major Track'].strip()
    major_track = 'GT'

    if major_track_str == 'Cyber Security Track':
        major_track = 'CST'
    elif major_track_str == 'Data Science Track':
        major_track = 'DST'
    elif major_track_str == 'Artificial Intelligence and Machine Learning Track':
        major_track = 'AI/MLT'
    elif major_track_str == 'Computer Vision and Robotics Track':
        major_track = 'CV/RT'
    else:
        remarks = ''.join([remarks,'\nTrack is ',major_track_str])
    major_track = null_prevention(major_track)


    year_str = row['Year'].strip()

    year = 0
    if year_str == 'First Year':
        year = 1
    if year_str == 'Second Year':
        year = 2
    if year_str == 'Third Year':
        year = 3
    if year_str == 'Fourth Year':
        year = 4
    if year_str == 'Fifth Year':
        year = 5

    hours_passed = int(row['Hours Passed'])

    git_hub = null_prevention(row['GitHub'])

    linkedin = null_prevention(row['LinkedIn'])

    student_resume = null_prevention(row['Resume'])

    remarks = null_prevention(remarks)

    cursor.execute(f'CALL insert_student_from_sheets({uni_id},{first_name},{last_name},{email},{year},{major},{major_track},{hours_passed},{git_hub},{linkedin},{student_resume},{remarks})')

db.commit()
print('done')