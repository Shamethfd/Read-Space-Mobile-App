import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../widgets/library_bottom_navigation.dart';

enum _BookingStage { map, time, review, checkIn }

enum _SeatState { available, occupied, reserved }

class SeatBookingFlow extends StatefulWidget {
  const SeatBookingFlow({super.key});

  @override
  State<SeatBookingFlow> createState() => _SeatBookingFlowState();
}

class _SeatBookingFlowState extends State<SeatBookingFlow> {
  static const _blue = Color(0xFF1683F3);
  static const _background = Color(0xFFF6F9FC);
  static const _navy = Color(0xFF17212B);
  static const _muted = Color(0xFF6285AC);
  static const _border = Color(0xFFE5EBF0);
  static const _green = Color(0xFF0DBB88);
  static const _occupied = Color(0xFFFFB4B8);
  static const _reserved = Color(0xFFFF9D42);

  _BookingStage _stage = _BookingStage.map;
  bool _groupMode = false;
  final Set<String> _filters = {'Near Power Outlet'};
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = '10:00 - 12:00';
  String _selectedSeat = 'B-12';
  Timer? _timer;
  int _secondsRemaining = 15 * 60;
  bool _checkedIn = false;
  bool _expired = false;

  final _dates = List<DateTime>.generate(
    5,
    (index) => DateTime.now().add(Duration(days: index + 1)),
  );
  final _slots = const [
    '08:00 - 10:00',
    '10:00 - 12:00',
    '12:00 - 14:00',
    '14:00 - 16:00',
    '16:00 - 18:00',
    '18:00 - 20:00',
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _secondsRemaining = 15 * 60;
    _expired = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _checkedIn) return;
      if (_secondsRemaining <= 1) {
        _timer?.cancel();
        setState(() {
          _secondsRemaining = 0;
          _expired = true;
        });
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _goTo(_BookingStage stage) {
    setState(() => _stage = stage);
    if (stage == _BookingStage.checkIn) _startCountdown();
  }

  String get _dateLabel =>
      '${_weekday(_selectedDate.weekday)}, ${_selectedDate.day} ${_month(_selectedDate.month)} ${_selectedDate.year}';

  String _weekday(int day) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][day - 1];

  String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _MockStatusBar(),
                  const SizedBox(height: 8),
                  _BookingHeader(
                    title: _title,
                    subtitle: _subtitle,
                    onBack: _stage == _BookingStage.map
                        ? () => Navigator.pop(context)
                        : () => _goTo(_BookingStage.values[_stage.index - 1]),
                  ),
                  const SizedBox(height: 20),
                  _buildStage(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: LibraryBottomNavigation(
            selectedIndex: 2,
            onSelected: (index) {
              if (index == 0 || index == 1 || index == 3) {
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
  }

  String get _title => switch (_stage) {
    _BookingStage.map => 'Interactive Floor Map',
    _BookingStage.time => 'Select Time Slot',
    _BookingStage.review => 'Confirm Reservation',
    _BookingStage.checkIn => 'Seat Check-in',
  };

  String? get _subtitle => switch (_stage) {
    _BookingStage.map => 'University Central Library',
    _BookingStage.time => 'Reserve Desk B-12',
    _BookingStage.review => null,
    _BookingStage.checkIn => null,
  };

  Widget _buildStage() => switch (_stage) {
    _BookingStage.map => _buildMap(),
    _BookingStage.time => _buildTimeSelection(),
    _BookingStage.review => _buildReview(),
    _BookingStage.checkIn => _buildCheckIn(),
  };

  Widget _buildMap() {
    const mapSeats = [
      ['A-01', 'A-02', 'A-03', 'A-04'],
      ['A-05', 'A-06', 'A-07', 'A-08'],
      ['B-09', 'B-10', 'B-11', 'B-12'],
      ['B-13', 'B-14', 'B-15', 'B-16'],
    ];
    final states = [
      _SeatState.available,
      _SeatState.occupied,
      _SeatState.available,
      _SeatState.reserved,
      _SeatState.available,
      _SeatState.available,
      _SeatState.occupied,
      _SeatState.available,
      _SeatState.reserved,
      _SeatState.available,
      _SeatState.occupied,
      _SeatState.available,
      _SeatState.available,
      _SeatState.reserved,
      _SeatState.available,
      _SeatState.available,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interactive Floor Map',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _navy,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'University Central Library',
          style: TextStyle(fontSize: 12, color: _muted),
        ),
        const SizedBox(height: 16),
        _SegmentedControl(
          labels: const ['Individual', 'Group'],
          selectedIndex: _groupMode ? 1 : 0,
          onSelected: (index) => setState(() => _groupMode = index == 1),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterPill(
              label: 'Near Power Outlet',
              icon: Icons.power,
              selected: _filters.contains('Near Power Outlet'),
              onTap: () => _toggleFilter('Near Power Outlet'),
            ),
            _FilterPill(
              label: 'Quiet Zone',
              icon: Icons.volume_off_outlined,
              selected: _filters.contains('Quiet Zone'),
              onTap: () => _toggleFilter('Quiet Zone'),
            ),
            _FilterPill(
              label: 'Window Seat',
              icon: Icons.window_outlined,
              selected: _filters.contains('Window Seat'),
              onTap: () => _toggleFilter('Window Seat'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SurfaceCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _LegendDot(color: _green, label: 'Available'),
                  _LegendDot(color: _occupied, label: 'Occupied'),
                  _LegendDot(color: _reserved, label: 'Reserved'),
                ],
              ),
              const Divider(height: 24, color: _border),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 16,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.92,
                ),
                itemBuilder: (context, index) {
                  final state = states[index];
                  final seat = mapSeats[index ~/ 4][index % 4];
                  return _SeatTile(
                    label: seat,
                    state: state,
                    onTap: state == _SeatState.available
                        ? () {
                            setState(() => _selectedSeat = seat);
                            _goTo(_BookingStage.time);
                          }
                        : null,
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login_outlined, size: 16, color: _muted),
                  SizedBox(width: 5),
                  const Text(
                    'MAIN ENTRANCE',
                    style: TextStyle(
                      fontSize: 10,
                      color: _muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _InfoStrip(text: '9 seats available on this floor'),
      ],
    );
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (!_filters.add(filter)) _filters.remove(filter);
    });
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Desk B-12',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                      ),
                    ),
                  ),
                  _Badge(label: 'Floor 2'),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Quiet Zone  🤫  ·  Power Outlet  🔌  ·  Window View  🪟',
                style: TextStyle(fontSize: 11, color: _muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const _SectionLabel('Select Date'),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final date in _dates)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _DateButton(
                    date: date,
                    selected: _sameDay(date, _selectedDate),
                    onTap: () => setState(() => _selectedDate = date),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 22),
        const _SectionLabel('Select Duration Block (2 hrs)'),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _slots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.45,
          ),
          itemBuilder: (context, index) {
            final slot = _slots[index];
            return _TimeSlotButton(
              slot: slot,
              selected: slot == _selectedSlot,
              onTap: () => setState(() => _selectedSlot = slot),
            );
          },
        ),
        const SizedBox(height: 18),
        const _InfoStrip(
          text: 'Booking Policy: Max 4 hours per day per student.',
          icon: Icons.info_outline,
        ),
        const SizedBox(height: 20),
        _PrimaryBookingButton(
          label: 'Continue',
          onPressed: () => _goTo(_BookingStage.review),
        ),
      ],
    );
  }

  Widget _buildReview() {
    final rows = [
      ('Reserved Seat', _selectedSeat, Icons.event_seat_outlined),
      ('Location', 'Floor 2, Central Library', Icons.location_on_outlined),
      ('Date', _dateLabel, Icons.calendar_today_outlined),
      ('Time Slot', _selectedSlot, Icons.access_time_outlined),
      ('Power Outlet', 'Available', Icons.power_outlined),
      ('Duration', '2 Hours', Icons.timelapse_outlined),
    ];
    return Column(
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: const BoxDecoration(
            color: Color(0xFFE7F2FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: _blue, size: 35),
        ),
        const SizedBox(height: 14),
        const Text(
          'Review Booking Details',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _navy,
          ),
        ),
        const SizedBox(height: 18),
        _SurfaceCard(
          child: Column(
            children: [
              for (var index = 0; index < rows.length; index++) ...[
                _DetailRow(
                  label: rows[index].$1,
                  value: rows[index].$2,
                  icon: rows[index].$3,
                ),
                if (index != rows.length - 1)
                  const Divider(height: 18, color: _border),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        _PrimaryBookingButton(
          label: 'Confirm Booking',
          onPressed: () => _goTo(_BookingStage.checkIn),
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: () => _goTo(_BookingStage.time),
          child: const Text(
            'Cancel',
            style: TextStyle(color: _blue, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckIn() {
    final remaining =
        '${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}';
    return Column(
      children: [
        _SurfaceCard(
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Desk B-12',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_dateLabel · $_selectedSlot',
                    style: const TextStyle(fontSize: 10, color: _muted),
                  ),
                  const SizedBox(height: 6),
                  _StatusBadge(
                    label: _expired
                        ? 'Released'
                        : (_checkedIn ? 'Checked in' : 'Waiting Check-in'),
                    active: _checkedIn,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SurfaceCard(
          shadow: true,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFFF3F5F7),
                child: QrImageView(
                  data:
                      'READSPACE-MOCK-$_selectedSeat-${_selectedDate.toIso8601String()}',
                  size: 190,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _expired
                    ? 'Reservation released'
                    : (_checkedIn
                          ? 'Checked in successfully'
                          : 'Scan at your seat'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _TimerPill(remaining: _expired ? '00:00' : remaining),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFE5A1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFB77B00),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attention Required',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _expired
                          ? 'This reservation was released because the check-in timer expired.'
                          : 'Please scan the QR code located at $_selectedSeat within ${_secondsRemaining ~/ 60 + 1} minutes of your slot start time, or your reservation will be auto-released for other students.',
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: _navy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _checkedIn || _expired
              ? null
              : () {
                  _timer?.cancel();
                  setState(() => _checkedIn = true);
                },
          icon: const Icon(Icons.touch_app_outlined),
          label: const Text('Check In Manually'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _blue,
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: _blue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _MockStatusBar extends StatelessWidget {
  const _MockStatusBar();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '9:41 AM',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF17212B),
          ),
        ),
        Row(
          children: [
            Icon(Icons.signal_cellular_alt, size: 13),
            SizedBox(width: 4),
            Icon(Icons.wifi, size: 13),
            SizedBox(width: 4),
            Icon(Icons.battery_full, size: 15),
          ],
        ),
      ],
    ),
  );
}

class _BookingHeader extends StatelessWidget {
  const _BookingHeader({
    required this.title,
    this.subtitle,
    required this.onBack,
  });
  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Back',
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(
            Icons.arrow_back,
            size: 19,
            color: Color(0xFF17212B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF17212B),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6285AC),
                  ),
                ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 19,
          backgroundColor: Color(0xFFE6DEFF),
          child: Icon(Icons.person_outline, color: Color(0xFF725BC2), size: 21),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.shadow = false});
  final Widget child;
  final bool shadow;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFE5EBF0)),
      boxShadow: shadow
          ? [
              const BoxShadow(
                color: Color(0x12000000),
                blurRadius: 16,
                offset: Offset(0, 5),
              ),
            ]
          : null,
    ),
    child: child,
  );
}

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1F7),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: index == selectedIndex
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: index == selectedIndex
                          ? const Color(0xFF1683F3)
                          : const Color(0xFF6285AC),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : const Color(0xFF6285AC);
    return ActionChip(
      avatar: Icon(icon, size: 14, color: foreground),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
      onPressed: onTap,
      backgroundColor: selected ? const Color(0xFF1683F3) : Colors.white,
      side: BorderSide(
        color: selected ? const Color(0xFF1683F3) : const Color(0xFFE5EBF0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    );
  }
}

/*
                      color: index == selectedIndex
                          ? const Color(0xFF1683F3)
                          : const Color(0xFF6285AC),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : const Color(0xFF6285AC);
    return ActionChip(
      avatar: Icon(icon, size: 14, color: foreground),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
      onPressed: onTap,
      backgroundColor: selected ? const Color(0xFF1683F3) : Colors.white,
      side: BorderSide(
        color: selected ? const Color(0xFF1683F3) : const Color(0xFFE5EBF0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    );
  }
}

*/

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(fontSize: 10, color: Color(0xFF6285AC)),
      ),
    ],
  );
}

class _SeatTile extends StatelessWidget {
  const _SeatTile({required this.label, required this.state, this.onTap});
  final String label;
  final _SeatState state;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _SeatState.available => const Color(0xFF0DBB88),
      _SeatState.occupied => const Color(0xFFFFB4B8),
      _SeatState.reserved => const Color(0xFFFF9D42),
    };
    return Semantics(
      button: onTap != null,
      label: '$label ${state.name}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (state == _SeatState.available)
                const Text(
                  'Book',
                  style: TextStyle(fontSize: 8, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.text, this.icon = Icons.info_outline});
  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F3FF),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF1683F3), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 11, color: Color(0xFF356B9B)),
          ),
        ),
      ],
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F3FF),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF1683F3),
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: Color(0xFF17212B),
    ),
  );
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.date,
    required this.selected,
    required this.onTap,
  });
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1683F3) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? const Color(0xFF1683F3) : const Color(0xFFE5EBF0),
        ),
      ),
      child: Column(
        children: [
          Text(
            const [
              'Mon',
              'Tue',
              'Wed',
              'Thu',
              'Fri',
              'Sat',
              'Sun',
            ][date.weekday - 1],
            style: TextStyle(
              fontSize: 9,
              color: selected ? Colors.white : const Color(0xFF6285AC),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : const Color(0xFF17212B),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TimeSlotButton extends StatelessWidget {
  const _TimeSlotButton({
    required this.slot,
    required this.selected,
    required this.onTap,
  });
  final String slot;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(
      Icons.access_time,
      size: 15,
      color: selected ? const Color(0xFF1683F3) : const Color(0xFF6285AC),
    ),
    label: Text(
      slot,
      style: TextStyle(
        fontSize: 10,
        color: selected ? const Color(0xFF1683F3) : const Color(0xFF17212B),
        fontWeight: FontWeight.w700,
      ),
    ),
    style: OutlinedButton.styleFrom(
      backgroundColor: selected ? const Color(0xFFE8F3FF) : Colors.white,
      side: BorderSide(
        color: selected ? const Color(0xFF1683F3) : const Color(0xFFE5EBF0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

class _PrimaryBookingButton extends StatelessWidget {
  const _PrimaryBookingButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1683F3),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1683F3), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6285AC)),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF17212B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.active});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: active ? const Color(0xFFE3FAF3) : const Color(0xFFFFF3CB),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: active ? const Color(0xFF078665) : const Color(0xFF9D6D00),
      ),
    ),
  );
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.remaining});
  final String remaining;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE5EBF0)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF1683F3)),
        const SizedBox(width: 6),
        Text(
          remaining,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF17212B),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
