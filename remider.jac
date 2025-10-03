node Reminder {
    has datetime due_time;
    has str message;

    can display with {
        report "Reminder: " + message + " at " + str(due_time);
    }
}

walker User {
    has list reminders;

    can create_reminder with {
        obj = spawn node Reminder;
        obj.message = input("Enter reminder message: ");
        obj.due_time = datetime.fromisoformat(input("Enter due time (YYYY-MM-DD HH:MM): "));
        take --> obj;
        report " Reminder created!";
    }

    can show_reminders with {
        report " Your reminders:";
        for r in neighbors {
            if r.type == Reminder {
                r.display();
            }
        }
    }

    can check_due with {
        now = datetime.now();
        for r in neighbors {
            if r.type == Reminder and r.due_time <= now {
                report " Reminder due: " + r.message;
                destroy --> r; # remove after triggering
            }
        }
    }
}

walker init {
    can run with {
        user = spawn walker User;
        user.create_reminder();
        user.show_reminders();

        # schedule reminder checking every 1 minute
        schedule every 60s user.check_due();
    }
}
