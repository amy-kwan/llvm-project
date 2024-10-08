//===-- Collection of utils for mktime and friends --------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_SRC_TIME_TIME_UTILS_H
#define LLVM_LIBC_SRC_TIME_TIME_UTILS_H

#include <stddef.h> // For size_t.

#include "src/__support/common.h"
#include "src/__support/macros/config.h"
#include "src/errno/libc_errno.h"
#include "src/time/mktime.h"

#include <stdint.h>

namespace LIBC_NAMESPACE_DECL {
namespace time_utils {

enum Month : int {
  JANUARY,
  FEBRUARY,
  MARCH,
  APRIL,
  MAY,
  JUNE,
  JULY,
  AUGUST,
  SEPTEMBER,
  OCTOBER,
  NOVEMBER,
  DECEMBER
};

struct TimeConstants {
  static constexpr int SECONDS_PER_MIN = 60;
  static constexpr int MINUTES_PER_HOUR = 60;
  static constexpr int HOURS_PER_DAY = 24;
  static constexpr int DAYS_PER_WEEK = 7;
  static constexpr int MONTHS_PER_YEAR = 12;
  static constexpr int DAYS_PER_NON_LEAP_YEAR = 365;
  static constexpr int DAYS_PER_LEAP_YEAR = 366;

  static constexpr int SECONDS_PER_HOUR = SECONDS_PER_MIN * MINUTES_PER_HOUR;
  static constexpr int SECONDS_PER_DAY = SECONDS_PER_HOUR * HOURS_PER_DAY;
  static constexpr int NUMBER_OF_SECONDS_IN_LEAP_YEAR =
      DAYS_PER_LEAP_YEAR * SECONDS_PER_DAY;

  static constexpr int TIME_YEAR_BASE = 1900;
  static constexpr int EPOCH_YEAR = 1970;
  static constexpr int EPOCH_WEEK_DAY = 4;

  // For asctime the behavior is undefined if struct tm's tm_wday or tm_mon are
  // not within the normal ranges as defined in <time.h>, or if struct tm's
  // tm_year exceeds {INT_MAX}-1990, or if the below asctime_internal algorithm
  // would attempt to generate more than 26 bytes of output (including the
  // terminating null).
  static constexpr int ASCTIME_BUFFER_SIZE = 256;
  static constexpr int ASCTIME_MAX_BYTES = 26;

  /* 2000-03-01 (mod 400 year, immediately after feb29 */
  static constexpr int64_t SECONDS_UNTIL2000_MARCH_FIRST =
      (946684800LL + SECONDS_PER_DAY * (31 + 29));
  static constexpr int WEEK_DAY_OF2000_MARCH_FIRST = 3;

  static constexpr int DAYS_PER400_YEARS =
      (DAYS_PER_NON_LEAP_YEAR * 400) + (400 / 4) - 3;
  static constexpr int DAYS_PER100_YEARS =
      (DAYS_PER_NON_LEAP_YEAR * 100) + (100 / 4) - 1;
  static constexpr int DAYS_PER4_YEARS = (DAYS_PER_NON_LEAP_YEAR * 4) + 1;

  // The latest time that can be represented in this form is 03:14:07 UTC on
  // Tuesday, 19 January 2038 (corresponding to 2,147,483,647 seconds since the
  // start of the epoch). This means that systems using a 32-bit time_t type are
  // susceptible to the Year 2038 problem.
  static constexpr int END_OF32_BIT_EPOCH_YEAR = 2038;

  static constexpr time_t OUT_OF_RANGE_RETURN_VALUE = -1;
};

// Update the "tm" structure's year, month, etc. members from seconds.
// "total_seconds" is the number of seconds since January 1st, 1970.
extern int64_t update_from_seconds(int64_t total_seconds, struct tm *tm);

// TODO(michaelrj): move these functions to use ErrorOr instead of setting
// errno. They always accompany a specific return value so we only need the one
// variable.

// POSIX.1-2017 requires this.
LIBC_INLINE time_t out_of_range() {
#ifdef EOVERFLOW
  // For non-POSIX uses of the standard C time functions, where EOVERFLOW is
  // not defined, it's OK not to set errno at all. The plain C standard doesn't
  // require it.
  libc_errno = EOVERFLOW;
#endif
  return TimeConstants::OUT_OF_RANGE_RETURN_VALUE;
}

LIBC_INLINE void invalid_value() { libc_errno = EINVAL; }

LIBC_INLINE char *asctime(const struct tm *timeptr, char *buffer,
                          size_t bufferLength) {
  if (timeptr == nullptr || buffer == nullptr) {
    invalid_value();
    return nullptr;
  }
  if (timeptr->tm_wday < 0 ||
      timeptr->tm_wday > (TimeConstants::DAYS_PER_WEEK - 1)) {
    invalid_value();
    return nullptr;
  }
  if (timeptr->tm_mon < 0 ||
      timeptr->tm_mon > (TimeConstants::MONTHS_PER_YEAR - 1)) {
    invalid_value();
    return nullptr;
  }

  // TODO(rtenneti): i18n the following strings.
  static const char *week_days_name[TimeConstants::DAYS_PER_WEEK] = {
      "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};

  static const char *months_name[TimeConstants::MONTHS_PER_YEAR] = {
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

  // TODO(michaelr): look into removing this call to __builtin_snprintf that may
  // be emitted as a call to snprintf. Alternatively, look into using our
  // internal printf machinery.
  int written_size = __builtin_snprintf(
      buffer, bufferLength, "%.3s %.3s%3d %.2d:%.2d:%.2d %d\n",
      week_days_name[timeptr->tm_wday], months_name[timeptr->tm_mon],
      timeptr->tm_mday, timeptr->tm_hour, timeptr->tm_min, timeptr->tm_sec,
      TimeConstants::TIME_YEAR_BASE + timeptr->tm_year);
  if (written_size < 0)
    return nullptr;
  if (static_cast<size_t>(written_size) >= bufferLength) {
    out_of_range();
    return nullptr;
  }
  return buffer;
}

LIBC_INLINE struct tm *gmtime_internal(const time_t *timer, struct tm *result) {
  int64_t seconds = *timer;
  // Update the tm structure's year, month, day, etc. from seconds.
  if (update_from_seconds(seconds, result) < 0) {
    out_of_range();
    return nullptr;
  }

  return result;
}

// TODO: localtime is not yet implemented and a temporary solution is to
//       use gmtime, https://github.com/llvm/llvm-project/issues/107597
LIBC_INLINE struct tm *localtime(const time_t *t_ptr) {
  static struct tm result;
  return time_utils::gmtime_internal(t_ptr, &result);
}

} // namespace time_utils
} // namespace LIBC_NAMESPACE_DECL

#endif // LLVM_LIBC_SRC_TIME_TIME_UTILS_H
