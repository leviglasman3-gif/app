import sys

with open('lib/zmanim_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# We'll replace the entire build method again with updated styles.
# Find start and end of build method.
start = None
for i, line in enumerate(lines):
    if line.strip() == '@override' and i+1 < len(lines) and 'Widget build(BuildContext context)' in lines[i+1]:
        start = i
        break
if start is None:
    print('Could not find build method')
    sys.exit(1)

# Find end: the line that has '  }' and after that the next line starts with '  Widget _buildBody'
end = None
for i in range(start, len(lines)):
    if lines[i].rstrip() == '  }' and i+1 < len(lines) and lines[i+1].strip().startswith('Widget _buildBody'):
        end = i+1  # exclusive end (we want to replace up to but not including the closing brace? Actually we want to replace from start to the line before 'Widget _buildBody')
        break
if end is None:
    print('Could not find end of build method')
    sys.exit(1)

print(f'Replacing lines {start} to {end}')

new_build = '''  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Theme.of(context).colorScheme.inversePrimary,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hamburger (leading) - 20% width -> flex 2 out of 10
              Expanded(
                flex: 2,
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    // TODO: open drawer
                  },
                  iconSize: 30,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.expand(),
                ),
              ),
              // Title - 30% width -> flex 3
              Expanded(
                flex: 3,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.noScaling,
                  ),
                  child: const Center(
                    child: Text(
                      'Zmanim',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              // Today button - part of actions, allocate flex 2 (20%)
              Expanded(
                flex: 2,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.noScaling,
                  ),
                  child: TextButton(
                    onPressed: _goToTodayOrReload,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              // IconButton left - flex 1 (10%)
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 30,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.expand(),
                  onPressed: _goToPreviousDay,
                ),
              ),
              // IconButton calendar - flex 1 (10%)
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  iconSize: 30,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.expand(),
                  onPressed: _pickDate,
                ),
              ),
              // IconButton right - flex 1 (10%)
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  iconSize: 30,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.expand(),
                  onPressed: _goToNextDay,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }
'''

lines[start:end] = [new_build]
with open('lib/zmanim_screen.dart', 'w', encoding='utf-8') as f:
    f.writelines(lines)
print('Done')