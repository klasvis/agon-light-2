#ifndef THREAD_SAFE_VARIANT_DEQUE_H
#define THREAD_SAFE_VARIANT_DEQUE_H

#include <deque>
#include <mutex>
#include <variant>
#include <algorithm>

template<typename... Ts>
class ThreadSafeVariantDeque {
public:
	using value_type = std::variant<Ts...>;

private:
	std::deque<value_type> deque_;
	mutable std::mutex mutex_;

	template<typename U>
	bool containsType_unlocked() const {
		static_assert((std::disjunction_v<std::is_same<U, Ts>...>),
					"Type U must be one of the alternatives in std::variant<Ts...>");
		return std::any_of(deque_.begin(), deque_.end(), [](const value_type& v) {
			return std::holds_alternative<U>(v);
		});
	}

public:
	// Push to back
	template<typename T>
	void push(T&& item) {
		std::lock_guard<std::mutex> lock(mutex_);
		deque_.emplace_back(std::forward<T>(item));
	}

	// Push to back if an item of the given type not already present
	template<typename T>
	bool pushUnique(T&& item) {
		std::lock_guard<std::mutex> lock(mutex_);
		if (!containsType_unlocked<T>()) {
			deque_.emplace_back(std::forward<T>(item));
			return true;
		}
		return false;
	}

	// Push to back if a value of the given type not already present
	// template<typename T>
	// bool pushUniqueValue(T&& item) {
	// 	std::lock_guard<std::mutex> lock(mutex_);
		
	// 	// Check if this specific VALUE exists
	// 	bool valueExists = std::any_of(deque_.begin(), deque_.end(), [&item](const value_type& v) {
	// 		if (std::holds_alternative<T>(v)) {
	// 			return std::get<T>(v) == item;
	// 		}
	// 		return false;
	// 	});
		
	// 	if (!valueExists) {
	// 		deque_.emplace_back(std::forward<T>(item));
	// 		return true;
	// 	}
	// 	return false;
	// }

	// Get the next item without removing it
	bool peek(value_type& item) const {
		std::lock_guard<std::mutex> lock(mutex_);
		if (deque_.empty()) {
			return false;
		}
		item = deque_.front();	// Copy the front item
		return true;
	}

	// Pop from front
	bool pop(value_type& item) {
		std::lock_guard<std::mutex> lock(mutex_);
		if (deque_.empty()) {
			return false;
		}
		item = std::move(deque_.front());
		deque_.pop_front();
		return true;
	}

	// Pop with no return values
	void pop() {
		std::lock_guard<std::mutex> lock(mutex_);
		if (!deque_.empty()) {
			deque_.pop_front();
		}
	}

	bool empty() const {
		std::lock_guard<std::mutex> lock(mutex_);
		return deque_.empty();
	}

	size_t size() const {
		std::lock_guard<std::mutex> lock(mutex_);
		return deque_.size();
	}

	template<typename U>
	bool containsType() const {
		std::lock_guard<std::mutex> lock(mutex_);
		return containsType_unlocked<U>();
	}
};

#endif // THREAD_SAFE_VARIANT_DEQUE_H
