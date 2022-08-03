import pyodbc 
conn = pyodbc.connect('Driver={MariaODBC};'
                      'Server=localhost;'
                      'Database=dfr;'
                      'Trusted_Connection=yes;')

cursor = conn.cursor()

cursor.execute('''
                INSERT INTO DFR1 (Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Deskripsi_EventPaket_Input_Output)
                VALUES
                ('888', '888', '888', '888', '888')
                ''')
conn.commit()