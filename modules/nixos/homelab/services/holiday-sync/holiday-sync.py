import datetime as dt
import os
import uuid

import caldav
import holidays
from icalendar import Calendar, Event

UID_NAMESPACE = uuid.UUID("773b57f5-08c3-40ce-b492-13081bab26e4")
UID_SUFFIX = "@pt-holidays-sync"


def build_uid(holiday_date: dt.date) -> str:
    return (
        f"pt-holiday-{uuid.uuid5(UID_NAMESPACE, holiday_date.isoformat())}{UID_SUFFIX}"
    )


def make_event(holiday_date: dt.date, name: str) -> Event:
    event = Event()
    event.add("uid", build_uid(holiday_date))
    event.add("summary", name)
    event.add("dtstart", holiday_date)
    event.add("dtend", holiday_date + dt.timedelta(days=1))
    event.add("dtstamp", dt.datetime.now(dt.timezone.utc))
    event.add("transp", "TRANSPARENT")
    return event


def get_or_create_calendar(principal, cal_path, cal_name):
    try:
        calendar = principal.calendar(cal_url=cal_path)
        calendar.events()
        return calendar
    except Exception:
        cal_id = cal_path.rstrip("/").rsplit("/", 1)[-1]
        return principal.make_calendar(name=cal_name, cal_id=cal_id)


def main():
    url = os.environ["CALDAV_URL"]
    username = os.environ["CALDAV_USERNAME"]
    cal_path = os.environ["CALDAV_CALENDAR_PATH"]
    cal_name = os.environ.get("CALDAV_CALENDAR_NAME", "Holidays")
    years_ahead = int(os.environ.get("YEARS_AHEAD", "2"))

    password = os.environ["CALDAV_PASSWORD"]

    client = caldav.DAVClient(url=url, username=username, password=password)
    principal = client.principal()
    calendar = get_or_create_calendar(principal, cal_path, cal_name)

    today = dt.date.today()
    years = list(range(today.year, today.year + years_ahead + 1))
    pt_holidays = holidays.country_holidays("PT", years=years, language="pt_PT")

    for ev in calendar.events():
        uid = str(ev.icalendar_component.get("uid", ""))
        if uid.startswith("pt-holiday-") and uid.endswith(UID_SUFFIX):
            ev.delete()

    for holiday_date, name in sorted(pt_holidays.items()):
        cal = Calendar()
        cal.add("prodid", "-//pt-holidays-sync//EN")
        cal.add("version", "2.0")
        cal.add_component(make_event(holiday_date, name))
        calendar.save_event(cal.to_ical().decode("utf-8"))


if __name__ == "__main__":
    main()
