import UIKit; import HealthKit
class ViewController: UIViewController {
        let healthStore = HKHealthStore()
    let stepCountLabel = UILabel()
    override func viewDidLoad() {        super.viewDidLoad()
                setupUI()
        requestAuthorization()    }
        func setupUI() {
            stepCountLabel.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 50);        stepCountLabel.textAlignment = .center
            stepCountLabel.text = "Шагов сегодня: -";        view.addSubview(stepCountLabel)
                let sendMessageButton = UIButton(type: .system)
            sendMessageButton.frame = CGRect(x: 100, y: 200, width: 200, height: 50);        sendMessageButton.setTitle("Передать сообщение", for: .normal)
            sendMessageButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside);        view.addSubview(sendMessageButton)
                let setGoalButton = UIButton(type: .system)
            setGoalButton.frame = CGRect(x: 100, y: 300, width: 200, height: 50);        setGoalButton.setTitle("Установить цель", for: .normal)
            setGoalButton.addTarget(self, action: #selector(setGoal), for: .touchUpInside);        view.addSubview(setGoalButton)
    }
    func requestAuthorization() {        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { (success, error) in            if success {
                self.getTodaysStepCount()            } else {
                print("Ошибка при запросе авторизации для HealthKit: \(error?.localizedDescription ?? "")")            }
        }    }
        func getTodaysStepCount() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {            print("Шаги не поддерживаются на этом устройстве.")
            return        }
                let calendar = Calendar.current
            let now = Date();        let startOfDay = calendar.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate);        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
            DispatchQueue.main.async {                guard let result = result, let sum = result.sumQuantity() else {
                print("Не удалось получить данные о шагах: \(error?.localizedDescription ?? "")");                    return
            };                let stepCount = sum.doubleValue(for: HKUnit.count())
                self.stepCountLabel.text = "Шагов сегодня: \(Int(stepCount))"            }
            };        healthStore.execute(query)
    }
    @objc func sendMessage() {        let message = stepCountLabel.text ?? ""
        performSegue(withIdentifier: "segueToSecond", sender: message)    }
        @objc func setGoal() {
        performSegue(withIdentifier: "segueToSetGoal", sender: self)    }
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToSecond" {            if let destinationVC = segue.destination as? SecondViewController, let message = sender as? String {
                destinationVC.receivedMessage = message            }
        } else if segue.identifier == "segueToSetGoal" {
        }    }
}
class SecondViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!
    var receivedMessage: String?
    override func viewDidLoad() {        super.viewDidLoad()
        if let message = receivedMessage {            messageLabel.text = message
        }    }
        @IBAction func goBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)    }
}
class SetGoalViewController: UIViewController {
    @IBOutlet weak var goalTextField: UITextField!
    override func viewDidLoad() {        super.viewDidLoad()
                if let currentGoal = UserDefaults.standard.value(forKey: "StepGoal") as? Int {            goalTextField.text = "\(currentGoal)"
                }    }
                @IBAction func setGoal(_ sender: UIButton) {
                guard let goalText = goalTextField.text, let goal = Int(goalText) else {            return
                }
                print("Цель установлена на \(goal) шагов.")    }
        }
