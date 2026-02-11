# DSA Daily Roadmap - 60 Days to Interview Ready

**Goal:** Master all DSA patterns needed for FAANG interviews
**Timeline:** 60 days (2 months intensive)
**Daily Commitment:** 3-4 hours
**Total Problems:** 300+ (150 Easy, 120 Medium, 30 Hard)

---

## 📊 Overview by Topic

| Topic | Days | Easy | Medium | Hard | Key Patterns |
|-------|------|------|--------|------|--------------|
| Arrays & Strings | 8 | 20 | 15 | 3 | Two Pointers, Sliding Window |
| Linked Lists | 5 | 10 | 10 | 2 | Fast/Slow Pointers, Dummy Node |
| Stacks & Queues | 4 | 8 | 8 | 2 | Monotonic Stack |
| Hash Tables | 4 | 10 | 8 | 0 | Frequency Counter |
| Trees | 10 | 15 | 18 | 5 | DFS, BFS, Recursion |
| Graphs | 8 | 8 | 15 | 5 | BFS, DFS, Union Find |
| Dynamic Programming | 10 | 12 | 20 | 8 | Memoization, Tabulation |
| Backtracking | 5 | 5 | 10 | 3 | State Space Tree |
| Heaps | 3 | 5 | 8 | 1 | Top K Pattern |
| Tries | 3 | 4 | 6 | 1 | Prefix Matching |

---

## Week 1: Arrays & Strings (Day 1-7)

### Day 1: Array Basics & Two Pointers

**Theory (30 min):**
- Array time complexity: Access O(1), Search O(n), Insert O(n)
- Two Pointers pattern: Same direction vs Opposite direction
- When to use: Sorted arrays, palindromes, pairs/triplets

**Problems:**

#### 1. Two Sum (Easy) - LeetCode #1
**Problem:** Find two numbers that add up to target.

**Approaches:**
```javascript
// ❌ Brute Force - O(n²)
function twoSum(nums, target) {
  for (let i = 0; i < nums.length; i++) {
    for (let j = i + 1; j < nums.length; j++) {
      if (nums[i] + nums[j] === target) {
        return [i, j];
      }
    }
  }
}

// ✅ Hash Map - O(n)
function twoSum(nums, target) {
  const map = new Map();
  for (let i = 0; i < nums.length; i++) {
    const complement = target - nums[i];
    if (map.has(complement)) {
      return [map.get(complement), i];
    }
    map.set(nums[i], i);
  }
}
```

**Key Insights:**
- Use hash map to trade space for time
- Store (number → index) mapping
- Check complement before adding current

**Edge Cases:**
- Empty array
- No solution exists
- Duplicate numbers

---

#### 2. Remove Duplicates from Sorted Array (Easy) - LeetCode #26
**Problem:** Remove duplicates in-place, return new length.

**Approach - Two Pointers (Same Direction):**
```javascript
function removeDuplicates(nums) {
  if (nums.length === 0) return 0;

  let slow = 0; // Points to last unique element

  for (let fast = 1; fast < nums.length; fast++) {
    if (nums[fast] !== nums[slow]) {
      slow++;
      nums[slow] = nums[fast];
    }
  }

  return slow + 1;
}
```

**Pattern:** Slow/Fast Pointer (Same Direction)
- Slow: Position of last unique element
- Fast: Explores array
- When different: Move slow, copy value

**Time:** O(n), **Space:** O(1)

---

#### 3. Valid Palindrome (Easy) - LeetCode #125
**Problem:** Check if string is palindrome (ignoring non-alphanumeric).

**Approach - Two Pointers (Opposite Direction):**
```javascript
function isPalindrome(s) {
  let left = 0;
  let right = s.length - 1;

  while (left < right) {
    // Skip non-alphanumeric
    while (left < right && !isAlphanumeric(s[left])) left++;
    while (left < right && !isAlphanumeric(s[right])) right--;

    if (s[left].toLowerCase() !== s[right].toLowerCase()) {
      return false;
    }

    left++;
    right--;
  }

  return true;
}

function isAlphanumeric(char) {
  return /[a-zA-Z0-9]/.test(char);
}
```

**Pattern:** Two Pointers (Opposite Direction)
- Left starts at beginning, right at end
- Move towards center
- Compare characters

**Time:** O(n), **Space:** O(1)

---

#### 4. Container With Most Water (Medium) - LeetCode #11
**Problem:** Find two lines that form container with most water.

**Approach - Two Pointers (Greedy):**
```javascript
function maxArea(height) {
  let left = 0;
  let right = height.length - 1;
  let maxArea = 0;

  while (left < right) {
    const width = right - left;
    const minHeight = Math.min(height[left], height[right]);
    const area = width * minHeight;

    maxArea = Math.max(maxArea, area);

    // Move pointer with smaller height
    if (height[left] < height[right]) {
      left++;
    } else {
      right--;
    }
  }

  return maxArea;
}
```

**Key Insight:** Always move the pointer with smaller height (greedy choice).

**Time:** O(n), **Space:** O(1)

---

**Daily Practice Schedule:**
- Morning (1 hour): Solve 2 easy problems
- Afternoon (1 hour): Solve 1 medium problem
- Evening (1 hour): Review solutions, understand patterns

---

### Day 2: Sliding Window

**Theory (30 min):**
- Fixed vs Variable size window
- When to expand, when to shrink
- Template pattern

**Sliding Window Template:**
```javascript
function slidingWindow(arr) {
  let left = 0;
  let result = 0;

  for (let right = 0; right < arr.length; right++) {
    // Add arr[right] to window

    // Shrink window if invalid
    while (/* window invalid */) {
      // Remove arr[left] from window
      left++;
    }

    // Update result with valid window
    result = Math.max(result, right - left + 1);
  }

  return result;
}
```

**Problems:**

#### 1. Maximum Subarray (Easy) - LeetCode #53 (Kadane's Algorithm)
**Problem:** Find contiguous subarray with largest sum.

**Approach:**
```javascript
function maxSubArray(nums) {
  let maxSum = nums[0];
  let currentSum = nums[0];

  for (let i = 1; i < nums.length; i++) {
    // Either extend current subarray or start new one
    currentSum = Math.max(nums[i], currentSum + nums[i]);
    maxSum = Math.max(maxSum, currentSum);
  }

  return maxSum;
}
```

**Key Insight:** At each position, decide: start fresh or continue?

**Time:** O(n), **Space:** O(1)

---

#### 2. Longest Substring Without Repeating Characters (Medium) - LeetCode #3
**Problem:** Find length of longest substring without repeating chars.

**Approach - Variable Sliding Window:**
```javascript
function lengthOfLongestSubstring(s) {
  const charSet = new Set();
  let left = 0;
  let maxLength = 0;

  for (let right = 0; right < s.length; right++) {
    // Shrink window until no duplicate
    while (charSet.has(s[right])) {
      charSet.delete(s[left]);
      left++;
    }

    charSet.add(s[right]);
    maxLength = Math.max(maxLength, right - left + 1);
  }

  return maxLength;
}
```

**Pattern:** Variable window with Set for tracking

**Time:** O(n), **Space:** O(min(n, m)) where m = charset size

---

#### 3. Minimum Window Substring (Hard) - LeetCode #76
**Problem:** Find minimum window in S that contains all chars of T.

**Approach:**
```javascript
function minWindow(s, t) {
  const need = new Map();
  const window = new Map();

  // Count chars in t
  for (const char of t) {
    need.set(char, (need.get(char) || 0) + 1);
  }

  let left = 0;
  let minLen = Infinity;
  let minStart = 0;
  let matched = 0; // Number of chars matched

  for (let right = 0; right < s.length; right++) {
    const char = s[right];

    // Add to window
    window.set(char, (window.get(char) || 0) + 1);

    // Check if this char satisfies need
    if (need.has(char) && window.get(char) === need.get(char)) {
      matched++;
    }

    // Try to shrink window
    while (matched === need.size) {
      // Update result
      if (right - left + 1 < minLen) {
        minLen = right - left + 1;
        minStart = left;
      }

      // Shrink from left
      const leftChar = s[left];
      window.set(leftChar, window.get(leftChar) - 1);

      if (need.has(leftChar) && window.get(leftChar) < need.get(leftChar)) {
        matched--;
      }

      left++;
    }
  }

  return minLen === Infinity ? '' : s.substring(minStart, minStart + minLen);
}
```

**Key Insight:** Expand right to find valid window, shrink left to minimize.

**Time:** O(m + n), **Space:** O(m) where m = charset size

---

### Day 3: Prefix Sum & Subarray Problems

**Theory (30 min):**
- Prefix sum: Precompute cumulative sums
- Range sum query in O(1)
- Subarray sum = prefix[right] - prefix[left-1]

**Problems:**

#### 1. Subarray Sum Equals K (Medium) - LeetCode #560
**Problem:** Count subarrays with sum equal to k.

**Approach - Prefix Sum + Hash Map:**
```javascript
function subarraySum(nums, k) {
  const prefixSumCount = new Map();
  prefixSumCount.set(0, 1); // Base case: sum 0 occurs once

  let count = 0;
  let currentSum = 0;

  for (const num of nums) {
    currentSum += num;

    // If (currentSum - k) exists, we found subarray(s)
    const target = currentSum - k;
    if (prefixSumCount.has(target)) {
      count += prefixSumCount.get(target);
    }

    // Add current sum to map
    prefixSumCount.set(currentSum, (prefixSumCount.get(currentSum) || 0) + 1);
  }

  return count;
}
```

**Key Insight:** Use hash map to store (prefix sum → count)

**Time:** O(n), **Space:** O(n)

---

#### 2. Product of Array Except Self (Medium) - LeetCode #238
**Problem:** Return array where output[i] = product of all elements except nums[i].

**Approach - Prefix/Suffix Products:**
```javascript
function productExceptSelf(nums) {
  const n = nums.length;
  const result = new Array(n);

  // Compute prefix products (left to right)
  result[0] = 1;
  for (let i = 1; i < n; i++) {
    result[i] = result[i - 1] * nums[i - 1];
  }

  // Compute suffix products and multiply (right to left)
  let suffixProduct = 1;
  for (let i = n - 1; i >= 0; i--) {
    result[i] *= suffixProduct;
    suffixProduct *= nums[i];
  }

  return result;
}
```

**Key Insight:** Two passes - prefix then suffix

**Time:** O(n), **Space:** O(1) (output array doesn't count)

---

[Continue with Days 4-7 covering more array/string problems...]

---

## Week 2: Linked Lists (Day 8-12)

### Day 8: Linked List Basics

**Theory (30 min):**
- Singly vs Doubly linked list
- Dummy head technique
- Fast/Slow pointer pattern (Floyd's algorithm)

**Problems:**

#### 1. Reverse Linked List (Easy) - LeetCode #206
**Problem:** Reverse a singly linked list.

**Approach - Iterative:**
```javascript
function reverseList(head) {
  let prev = null;
  let current = head;

  while (current !== null) {
    const next = current.next; // Save next
    current.next = prev;        // Reverse link
    prev = current;             // Move prev forward
    current = next;             // Move current forward
  }

  return prev;
}
```

**Approach - Recursive:**
```javascript
function reverseList(head) {
  if (head === null || head.next === null) {
    return head;
  }

  const newHead = reverseList(head.next);
  head.next.next = head; // Reverse link
  head.next = null;      // Break old link

  return newHead;
}
```

**Time:** O(n), **Space:** O(1) iterative, O(n) recursive (call stack)

---

#### 2. Linked List Cycle (Easy) - LeetCode #141
**Problem:** Detect if linked list has a cycle.

**Approach - Fast/Slow Pointer (Floyd's):**
```javascript
function hasCycle(head) {
  let slow = head;
  let fast = head;

  while (fast !== null && fast.next !== null) {
    slow = slow.next;       // Move 1 step
    fast = fast.next.next;  // Move 2 steps

    if (slow === fast) {
      return true; // Cycle detected
    }
  }

  return false;
}
```

**Key Insight:** Fast catches up to slow if there's a cycle.

**Time:** O(n), **Space:** O(1)

---

#### 3. Merge Two Sorted Lists (Easy) - LeetCode #21
**Problem:** Merge two sorted linked lists.

**Approach - Dummy Head:**
```javascript
function mergeTwoLists(l1, l2) {
  const dummy = { val: 0, next: null };
  let current = dummy;

  while (l1 !== null && l2 !== null) {
    if (l1.val <= l2.val) {
      current.next = l1;
      l1 = l1.next;
    } else {
      current.next = l2;
      l2 = l2.next;
    }
    current = current.next;
  }

  // Attach remaining
  current.next = l1 !== null ? l1 : l2;

  return dummy.next;
}
```

**Key Technique:** Dummy head simplifies edge cases.

**Time:** O(n + m), **Space:** O(1)

---

### Day 9: Advanced Linked List

#### 1. Remove Nth Node From End of List (Medium) - LeetCode #19
**Problem:** Remove the nth node from the end in one pass.

**Approach - Two Pointers:**
```javascript
function removeNthFromEnd(head, n) {
  const dummy = { val: 0, next: head };
  let first = dummy;
  let second = dummy;

  // Move first n+1 steps ahead
  for (let i = 0; i <= n; i++) {
    first = first.next;
  }

  // Move both until first reaches end
  while (first !== null) {
    first = first.next;
    second = second.next;
  }

  // Remove node
  second.next = second.next.next;

  return dummy.next;
}
```

**Key Insight:** Maintain gap of n between pointers.

**Time:** O(n), **Space:** O(1)

---

[Continue with more problems...]

---

## Complete 60-Day Schedule Summary

### Week 1-2: Foundations
- Arrays & Strings (8 days): 38 problems
- Linked Lists (5 days): 22 problems

### Week 3-4: Core Data Structures
- Stacks & Queues (4 days): 18 problems
- Hash Tables (4 days): 18 problems
- Trees (10 days): 38 problems

### Week 5-6: Advanced Algorithms
- Graphs (8 days): 28 problems
- Dynamic Programming (10 days): 40 problems

### Week 7-8: Specialized Topics
- Backtracking (5 days): 18 problems
- Heaps (3 days): 14 problems
- Tries (3 days): 11 problems

### Week 9: Review & Mock Interviews
- Day 57-58: Review hardest problems
- Day 59-60: Full mock interviews

---

## 📝 Pattern Recognition Cheat Sheet

### 1. Two Pointers
**When to use:**
- Sorted array problems
- Palindrome checks
- Pair/triplet problems
- Removing duplicates

**Problems:**
- Two Sum II (Sorted)
- 3Sum
- Container With Most Water
- Valid Palindrome

---

### 2. Sliding Window
**When to use:**
- Substring problems
- Contiguous subarray max/min
- Fixed or variable window size

**Problems:**
- Longest Substring Without Repeating Characters
- Minimum Window Substring
- Max Consecutive Ones

---

### 3. Fast & Slow Pointers
**When to use:**
- Cycle detection
- Finding middle element
- Nth node from end

**Problems:**
- Linked List Cycle
- Find Middle of Linked List
- Happy Number

---

### 4. Merge Intervals
**When to use:**
- Overlapping intervals
- Scheduling problems

**Problems:**
- Merge Intervals
- Insert Interval
- Meeting Rooms II

---

### 5. Cyclic Sort
**When to use:**
- Array with numbers in range [1, n]
- Finding missing/duplicate numbers

**Problems:**
- Find Missing Number
- Find All Duplicates

---

### 6. In-place Reversal of Linked List
**When to use:**
- Reverse linked list in sections

**Problems:**
- Reverse Linked List
- Reverse Linked List II
- Reverse Nodes in k-Group

---

### 7. Tree BFS (Level Order)
**When to use:**
- Level-by-level traversal
- Minimum depth/height

**Problems:**
- Binary Tree Level Order Traversal
- Zigzag Level Order
- Right Side View

---

### 8. Tree DFS
**When to use:**
- Path problems
- Sum problems
- Recursive tree problems

**Problems:**
- Path Sum
- Diameter of Tree
- Maximum Path Sum

---

### 9. Two Heaps
**When to use:**
- Finding median in stream
- Maintaining balance

**Problems:**
- Find Median from Data Stream
- Sliding Window Median

---

### 10. Top K Elements
**When to use:**
- Finding top/bottom K elements
- Frequency-based problems

**Problems:**
- Kth Largest Element
- Top K Frequent Elements
- K Closest Points

---

### 11. K-way Merge
**When to use:**
- Merging K sorted lists/arrays

**Problems:**
- Merge K Sorted Lists
- Smallest Range Covering Elements

---

### 12. Modified Binary Search
**When to use:**
- Sorted or rotated sorted array
- Finding boundaries

**Problems:**
- Search in Rotated Sorted Array
- Find First and Last Position
- Search in 2D Matrix

---

### 13. Bitwise XOR
**When to use:**
- Finding unique elements
- Bit manipulation

**Problems:**
- Single Number
- Two Single Numbers

---

### 14. Backtracking
**When to use:**
- Combinations/permutations
- Subsets
- Grid path problems

**Problems:**
- Permutations
- Combinations
- N-Queens
- Word Search

---

### 15. Dynamic Programming
**When to use:**
- Optimization problems (max/min)
- Counting problems
- Overlapping subproblems

**Common Patterns:**
- 0/1 Knapsack
- Unbounded Knapsack
- Longest Common Subsequence
- Palindromic Subsequence
- Fibonacci-like

**Problems:**
- Climbing Stairs
- Coin Change
- Longest Increasing Subsequence
- Edit Distance

---

## 📊 Daily Practice Routine

### Morning Session (1-1.5 hours)
1. Review yesterday's problems (15 min)
2. Solve 2 new problems (45 min)
3. Write down pattern/approach (15 min)

### Afternoon Session (1-1.5 hours)
1. Solve 1 medium problem (45 min)
2. Optimize solution (30 min)

### Evening Session (30-45 min)
1. Read others' solutions on LeetCode
2. Update pattern notes
3. Add problem to Anki for spaced repetition

---

## ✅ Progress Tracker Template

```
Week [X]: [Topic]

Day [X]: [Date]
Problems Solved:
1. [Problem Name] - [Difficulty] - ✅/❌
   Time Taken: [X] min
   Pattern: [Pattern Name]
   Mistakes: [What went wrong]

2. [Problem Name] - [Difficulty] - ✅/❌
   ...

Key Learnings:
-
-

Tomorrow's Focus:
-
```

---

## 🎯 Success Criteria

### By Day 30:
- [ ] Solved 150+ problems
- [ ] Comfortable with Arrays, Linked Lists, Trees
- [ ] Can identify 10+ patterns
- [ ] Solving Easy in < 15 min, Medium in < 30 min

### By Day 60:
- [ ] Solved 300+ problems
- [ ] Master all 15 patterns
- [ ] Solving Medium in < 25 min consistently
- [ ] Can approach Hard problems with confidence
- [ ] Completed 5+ mock interviews with 80%+ pass rate

---

**Start TODAY! Consistency beats intensity. 3-4 hours daily for 60 days will transform your DSA skills. You've got this! 🚀**
