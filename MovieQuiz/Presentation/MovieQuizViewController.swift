import UIKit

final class MovieQuizViewController: UIViewController {
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // настройка индикатора загрузки
        activityIndicator.hidesWhenStopped = true
        alertPresenter = AlertPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()
        presenter = MovieQuizPresenter(movieQuizViewController: self)
        showLoadingAnimation()
    }
    
    // MARK: - public
    func didRecieveNextQuestion(question: QuizQuestion?) {
        presenter.didRecieveNextQuestion(question: question)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        var message = result.text
        if let statisticService = statisticService {
            let bestGame = statisticService.store(correct: presenter.correctAnswers, total: presenter.questionAmount)
            
            let gamesCount = statisticService.gamesCount
            let totalAccuracy = statisticService.totalAccuracy
            
            let text =
                """
                Вы ответили на: \(presenter.correctAnswers) из \(presenter.questionAmount)
                Количество сыгранных квизов: \(gamesCount)
                Рекорд: \(bestGame.correct)(\(bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", totalAccuracy))%
                """
            message = text
        }
        let alertModel = AlertModel(title: result.title, message: message, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            
            presenter.restartGame()
        }
        alertPresenter?.show(in: self, alertModel: alertModel)
    }
    
    func showAnswerResult(isCorrect: Bool) {
       // метод красит рамку
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // если ответ пользователя верный, увеличить счетчик
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.imageView.layer.borderWidth = 0
            self.presenter.showNextQuestionOrResults()
        }
        blockAnswerButtons(blockButtons: false)
    }
    
    // функция блокировки кнопок ответа на вопрос. Принимает булевый параметр - блокировать да/нет
    func blockAnswerButtons(blockButtons: Bool) {
        yesButton.isEnabled = blockButtons
        noButton.isEnabled = blockButtons
    }
    
    
    func showLoadingAnimation() {
        activityIndicator.startAnimating()
    }
    
    func showNetworkError(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Попробовать еще раз",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            presenter.restartGame()
            presenter.correctAnswers = 0
        }
        alert.addAction(action)
    }
    
    //MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
}
